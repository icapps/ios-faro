import UIKit
import Faro
import Stella
import Foundation

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!

	/// !! It is important to retain the service until you have a result.
	let service = PostService()

    var serviceHandler: PostServiceHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Example using a service handler

        serviceHandler = PostServiceHandler(
            complete: {[weak self] (resultFunction) in
                    do {
                        let post = try resultFunction()
                        printAction(post)
                    } catch {
                        // Ignore errors are printed by default
                    }
                    DispatchQueue.main.async {
                        self?.label.text = "Performed call for post"
                    }
            }, completeArray : {[weak self] (resultFunction) in
                do {
                    let posts = try resultFunction()
                    printAction("Service Handler \(posts.map {"\($0.uuid): \($0.title ?? "")"}.reduce("") {"\($0)\n\($1)"})")
                    self?.serviceHandler?.session.session.getAllTasks {
                        print("After perform complete number of tasks \($0)")
                    }
                } catch {
                    // Ignore errors are printed by default
                }
                DispatchQueue.main.async {
                    self?.label.text = "Performed call for posts"
                }
        })

        let task1 = serviceHandler?.performArray()
        let task2 = serviceHandler?.performArray()
        let task3 = serviceHandler?.performArray()

        task1?.resume()
        serviceHandler?.session.session.getAllTasks {
            print("Before perform complete number of tasks \($0)")
        }

        task1?.suspend()

        task1?.resume()

        // Example using the more generic approach with a closure parameter

//        service.perform([Post].self) {[weak self] (resultFunction) in
//            DispatchQueue.main.async {
//                do {
//                    let posts = try resultFunction()
//                    self?.label.text = "Performed call for posts"
//                    printAction("Service \(posts.map {"\($0.uuid): \($0.title ?? "")"}.reduce("") {"\($0)\n\($1)"})")
//                } catch {
//                    printError(error)
//                }
//            }
//        }
//
//        // Test service queue
//
//        let serviceQueue = ServiceQueue(Configuration(baseURL: "http://jsonplaceholder.typicode.com")) {
//            printAction("🎉 queued call finished with failedTasks \(String(describing: $0)))")
//        }
//
//        let call = Call(path: "posts")
//        serviceQueue.perform([Post].self, call: call, complete: { (resultFunction) in
//            let posts = try? resultFunction()
//            printAction("ServiceQueue Task 1 finished  \(posts?.count ?? -1)")
//        })
//
//        serviceQueue.perform([Post].self, call: call, complete: { (resultFunction) in
//            let posts = try? resultFunction()
//            printAction("ServiceQueue Task 2 finished  \(posts?.count ?? -1)")
//        })
//
//        serviceQueue.perform([Post].self, call: call, complete: { (resultFunction) in
//            let posts = try? resultFunction()
//            printAction("ServiceQueue Task 3 finished  \(posts?.count ?? -1)")
//        })
//
//        serviceQueue.resumeAll()
//
//        // Test failure
//
//        failingService.perform(Post.self) { _ in
//            // should have printed failure
//        }
    }

}
