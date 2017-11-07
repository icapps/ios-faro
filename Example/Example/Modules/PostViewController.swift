import UIKit
import Faro
import Stella
import Foundation

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	/// !! It is important to retain the service until you have a result.!!
    private var postService: PostService?
    private var serviceHandler: PostServiceHandler?
    private var serviceQueue: PostServiceQueue?
    private var retryService: Service?
    private var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        postService = PostService()
        setupHandlers()
    }

    @IBAction func testRetry(_ sender: UIButton) {
        let failingCall = Call(path: "blaBla")

        failingCall.stub(statusCode: 401, data: nil, waitingTime: 0.1)

        let postCall = Call(path: "posts")
        postCall.stub(statusCode: 200, data: postsData, waitingTime: 3.0)

        FaroURLSession.shared().enableRetry { (_, _, response, _) -> Bool in
            guard let response = response as? HTTPURLResponse else {
                return false
            }
            return response.statusCode == 401
        }

        retryService = Service(call: failingCall)

        retryService?.perform(Post.self, complete: { (done) in
            print("⁉️ This should not succeed because of failure of other \(String(describing: try? done()))")
        })
        self.postService?.perform([Post].self, complete: { (done) in
            print("⁉️ This should not succeed because of failure of other \(String(describing: try? done()))")
        })

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
