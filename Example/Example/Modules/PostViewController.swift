import UIKit
import Faro
import Stella
import Foundation

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	/// !! It is important to retain the service until you have a result.!!
	let service = PostService()
    var serviceHandler: PostServiceHandler?

    private var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandlers()
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
        start(#function)
        service.perform([Post].self) { [weak self] (done) in
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
        start(#function)
        // You can put this everywhere and it will call the handlers you set in setupHandlers()
        serviceHandler?.performArray()
    }

    // MARK: - Queue

    @IBAction func getMultiplePostsRequestInQueue(_ sender: UIButton) {
        start(#function)
        let session = FaroURLSession(backendConfiguration: BackendConfiguration(baseURL: "http://jsonplaceholder.typicode.com"))
        let serviceQueue = ServiceQueue(session:session) { [weak self] failedTasks in
            self?.showError()
            printAction("🎉 queued call finished with failedTasks \(String(describing: failedTasks)))")
        }

        let call = Call(path: "posts")

        serviceQueue.perform([Post].self, call: call, complete: { [weak self] (done) in
            self?.show(try? done())
            printAction("ServiceQueue Task 1 finished")
        })

        serviceQueue.perform([Post].self, call: call, complete: { [weak self] (done) in
            self?.show(try? done())
            printAction("ServiceQueue Task 2 finished")
        })

        serviceQueue.perform([Post].self, call: call, complete: { [weak self] (done) in
            self?.show(try? done())
            printAction("ServiceQueue Task 3 finished")
        })

        serviceQueue.resumeAll()
    }

}
