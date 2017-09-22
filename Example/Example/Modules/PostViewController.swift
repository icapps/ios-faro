import UIKit
import Faro
import Stella
import Foundation

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!

	/// !! It is important to retain the service until you have a result.

    let failingService = Service(call: Call(path: "bullshit"),
                                 configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"))
	let service = Service(call: Call(path: "posts"),
                          configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"))

    override func viewDidLoad() {
        super.viewDidLoad()

        service.perform([Post].self) {[weak self] (resultFunction) in
            DispatchQueue.main.async {
                do {
                    let posts = try resultFunction()
                    self?.label.text = "Performed call for posts"
                    printAction("Service \(posts.map {"\($0.uuid): \($0.title ?? "")"}.reduce("") {"\($0)\n\($1)"})")
                } catch {
                    printError(error)
                }
            }
        }

        // Test service queue

        let serviceQueue = ServiceQueue(Configuration(baseURL: "http://jsonplaceholder.typicode.com")) {
            printAction("🎉 queued call finished with failedTasks \(String(describing: $0)))")
        }

        let call = Call(path: "posts")
        serviceQueue.perform([Post].self, call: call, complete: { (resultFunction) in
            let posts = try? resultFunction()
            printAction("ServiceQueue Task 1 finished  \(posts?.count ?? -1)")
        })

        serviceQueue.perform([Post].self, call: call, complete: { (resultFunction) in
            let posts = try? resultFunction()
            printAction("ServiceQueue Task 2 finished  \(posts?.count ?? -1)")
        })

        serviceQueue.perform([Post].self, call: call, complete: { (resultFunction) in
            let posts = try? resultFunction()
            printAction("ServiceQueue Task 3 finished  \(posts?.count ?? -1)")
        })

        serviceQueue.resumeAll()

        // Test failure

        failingService.perform(Post.self) {  _ in
            // should have printed failure
        }
    }

}
