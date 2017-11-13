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
    private var postService: Service?
    private var serviceHandler: PostServiceHandler?
    private var serviceQueue: PostServiceQueue?
    private var retryService: Service?
    private var posts = [Post]()
    private var authentication: Authentication = Authentication(token: "old token")

    override func viewDidLoad() {
        super.viewDidLoad()
        postService = PostService()
        setupHandlers()
    }

    @IBAction func testRetry(_ sender: UIButton) {
        var postCall = Call(path: "posts", parameter: [.httpHeader(["token": authentication.token])])
        let retryCall = Call(path: "retry")

        postCall.stub(statusCode: 401, data: nil, waitingTime: 0.1)
        retryCall.stub(statusCode: 200, dictionary: ["token": "refreshed token for header"], waitingTime: 0.1)

        FaroURLSession.shared().enableRetry(with: { (_, _, response, _) -> Bool in
            guard let response = response as? HTTPURLResponse else {
                return false
            }
            return response.statusCode == 401
        }, fixCancelledRequest: {[weak self] (originalRequest) -> URLRequest in

            guard let token = self?.authentication.token else {return originalRequest}

            var fixedRequest = originalRequest
            // Add the token we refreshed to the header field (this will override the previous value)
            fixedRequest.addValue(token, forHTTPHeaderField: "token")

            return fixedRequest
        }, performRetry: { [weak self] done in
            self?.retryService = Service(call: retryCall)
            self?.retryService?.perform(Authentication.self, complete: { (authenticationDone) in
                done {
                    self?.authentication = try authenticationDone()

                    guard let token = self?.authentication.token else {return}

                    // Because we are stubbing the requests for this example the following lines are needed. In your code this is not needed.
                    postCall = Call(path: "posts", method: .GET, parameter: [.httpHeader(["token": token])])
                    postCall.stub(statusCode: 200, data: postsData, waitingTime: 0.1)
                    // end stubbing code
                }

            })

        })

        postService = Service(call: postCall)

        postService?.perform(Post.self, complete: { (done) in
            print("⁉️ This should not succeed because of failure of other \(String(describing: try? done()))")
        })
//        self.postService?.perform([Post].self, complete: { (done) in
//            print("⁉️ This should not succeed because of failure of other \(String(describing: try? done()))")
//        })

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
        RequestStub.removeAllStubs()
        call.stub(statusCode: 200, data: postsData, waitingTime: 0.5)

        start(#function)
        postService?.perform([Post].self) { [weak self] (done) in
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
