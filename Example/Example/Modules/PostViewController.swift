import UIKit
import Faro
import Stella
import Foundation

struct Authentication: Decodable {
    let token: String
}

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	/// !! It is important to retain the service until you have a result.!!
    private var postService = [Service]()
    private var serviceHandler: PostServiceHandler?
    private var serviceQueue: PostServiceQueue?
    private var retryService: Service?
    private var posts = [Post]()
    private var authentication: Authentication = Authentication(token: "old token")

    override func viewDidLoad() {
        super.viewDidLoad()
//        postService.appPostService()
        setupHandlers()
    }

    @IBAction func testRetry(_ sender: UIButton) {
        let retryCall = Call(path: "retry")

        let waitingOffset: TimeInterval = 2 // Change this if you want request to go faster/slower
        "posts_A".stub(statusCode: 401, data: nil, waitingTime: 0.01)
        retryCall.stub(statusCode: 200, dictionary: ["token": "refreshed token for header"], waitingTime: waitingOffset + 10)
        "posts_B".stub(statusCode: 200, data: postsData, waitingTime: waitingOffset + 1)
        "posts_C".stub(statusCode: 200, data: postsData, waitingTime: waitingOffset + 2)
        "posts_D".stub(statusCode: 200, data: postsData, waitingTime: waitingOffset + 3)
        "posts_E".stub(statusCode: 400, dictionary: ["message": "this suspended task fails after retry fixed the request."], waitingTime: waitingOffset + 4)  // we add this but it is removed arter

        FaroURLSession.shared().enableRetry(with: { (_, _, response, _) -> Bool in
            guard let response = response as? HTTPURLResponse else {
                return false
            }
            return response.statusCode == 401
        }, fixCancelledRequest: {[weak self] (originalRequest) -> URLRequest in

            guard let token = self?.authentication.token else {return originalRequest}
            print("Fixing \(String(describing: originalRequest.url)) with token \(token)")
            var fixedRequest = originalRequest
            // Add the token we refreshed to the header field (this will override the previous value)
            fixedRequest.addValue(token, forHTTPHeaderField: "token")

            return fixedRequest
        }, performRetry: { [unowned self] done in
            self.retryService = Service(call: retryCall)

            return self.retryService!.perform(Authentication.self, complete: { (authenticationDone) in
                done {
                    self.authentication = try authenticationDone()

                    //: - Because of stub
                    //: We remove the old long waiting post response. With a real service this is not needed.
                    RequestStub.removeAllStubs()
                    "posts_A".stub(statusCode: 200, data: postsData, waitingTime: 0.01)
                    "posts_B".stub(statusCode: 200, data: postsData, waitingTime: waitingOffset + 1)
                    "posts_C".stub(statusCode: 200, data: postsData, waitingTime: waitingOffset + 2)
                    "posts_D".stub(statusCode: 400, dictionary: ["message": "this suspended task fails after retry fixed the request."], waitingTime: waitingOffset + 3)
                    //: - end stubbing code
                }

            })
        })

        postService.append(Service(call: Call(path:"posts_A")))

        postService[0].perform([Post].self, complete: { [weak self] (done) in
            let posts = try? done()
            self?.handlePosts(posts, service: "A - causes retry")
        })

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.postService.append(Service(call: Call(path: "posts_C")))
            self.postService[2].perform([Post].self, complete: { [weak self] (done) in
                let posts = try? done()
                self?.handlePosts(posts, service: "B - During retry")
            })

            self.postService.append(Service(call: Call(path: "posts_D")))
            self.postService[3].perform([Post].self, complete: { (done) in
                do {
                    _ = try done()
                    print("--- ⁉️ We should not get any posts for this. Should fail")
                } catch {
                    print("👌🏻 --- D -  During retry but response fails")
                }

            })

        }

        postService.append(Service(call: Call(path: "posts_B")))
        postService[1].perform([Post].self, complete: { [weak self] (done) in
            let posts = try? done()
            self?.handlePosts(posts, service: "C - Before Retry but after ")
        })

    }

    private func handlePosts(_ posts: [Post]?, service: String) {
        guard let posts = posts else {return}
        print("👌🏻 --- \(service) post received some posts")
        DispatchQueue.main.async {
            self.posts.append(contentsOf: posts)
            self.label.text = "Recieved posts \(self.posts.count)"
        }
    }

    fileprivate func showError() {
        DispatchQueue.main.async {
            self.label.text = "Error"
            self.activityIndicator.stopAnimating()
        }
    }

    fileprivate func show(_ posts: [Post]?) {
        guard let posts = posts else {
            DispatchQueue.main.async {
                self.showError()
            }
            return
        }
        self.posts.append(contentsOf: posts)

        DispatchQueue.main.async {
            self.label.text = "Did get \(self.posts.count) posts."
            self.activityIndicator.stopAnimating()
        }
    }
    fileprivate func start(_ function: String) {
        self.label.text = "\(function) ..."
        self.activityIndicator.startAnimating()
    }

    // MARK: - Closure parameter

    @IBAction func getPostsWithClosure(_ sender: UIButton) {
        let call = Call(path: "post")
        postService.removeAll()
        postService.append(Service(call: call))
        RequestStub.removeAllStubs()
        call.stub(statusCode: 200, data: postsData, waitingTime: 0.5)

        start(#function)
        postService[0].perform([Post].self) { [weak self] (done) in
            self?.show(try? done())
        }
    }

    // MARK: - Handlers

    private func setupHandlers() {
        serviceHandler = PostServiceHandler(completeArray : {[weak self] (done) in
               self?.show(try? done())
        })
    }

    @IBAction func getWithHandlers(_ sender: UIButton) {
        let call = Call(path: "post")
        RequestStub.removeAllStubs()
        call.stub(statusCode: 200, data: postsData, waitingTime: 0.5)

        start(#function)
        // You can put this everywhere and it will call the handlers you set in setupHandlers()
        serviceHandler?.performArray()
    }

    // MARK: - Queue

    @IBAction func getMultiplePostsRequestInQueue(_ sender: UIButton) {
        let call = Call(path: "post")
        RequestStub.removeAllStubs()
        call.stub(statusCode: 200, data: postsData, waitingTime: 0.5)

        start(#function)

        serviceQueue = PostServiceQueue { [weak self] failedTasks in
            self?.showError()
            printAction("🎉 queued call finished with failedTasks \(String(describing: failedTasks)))")
        }

        serviceQueue?.perform([Post].self, call: call, complete: { [weak self] (done) in
            self?.show(try? done())
            printAction("ServiceQueue Task 1 finished")
        })

        serviceQueue?.perform([Post].self, call: call, complete: { [weak self] (done) in
            self?.show(try? done())
            printAction("ServiceQueue Task 2 finished")
        })

        serviceQueue?.perform([Post].self, call: call, complete: { [weak self] (done) in
            self?.show(try? done())
            printAction("ServiceQueue Task 3 finished")
        })

        serviceQueue?.resumeAll()
    }

    // MARK: - Clear

    @IBAction func clearPosts(_ sender: Any) {
        print(#function)
        posts.removeAll()
    }

}
