import UIKit
import Faro
import Stella

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		let call = Call(path: "posts")

		let service = Service<Post>(call: call, deprecatedService:ExampleDeprecatedService())

		service.collection { [weak self] (resultFunction) in
			DispatchQueue.main.async {
				do {
					let posts = try resultFunction()
					self?.label.text = "Performed call for posts"
					printBreadcrumb("\(posts.map {"\($0.uuid): \(String(describing: $0.title))"})")
				} catch {
					printError(error)
				}
			}
		}


        let serviceQueue = Service<Post>(call: call, deprecatedService: ExampleDeprecatedServiceQueue { _ in
            printBreadcrumb("🎉 queued call finished")
        })

        serviceQueue.collection {
            printBreadcrumb("Task 1 finished  \(String(describing: try? $0()))")
        }

        serviceQueue.collection {
            printBreadcrumb("Task 2 finished  \(String(describing: try? $0()))")
        }

        serviceQueue.collection {
            printBreadcrumb("Task 3 finished \(String(describing: try? $0()))")
        }

        serviceQueue.resumeAll()
    }

}
