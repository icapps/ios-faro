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
					printAction("Service \(posts.map {"\($0.uuid): \($0.title ?? "")"}.reduce("") {"\($0)\n\($1)"})")
				} catch {
					printError(error)
				}
			}
		}

        let serviceQueue = ServiceQueue(deprecatedServiceQueue: ExampleDeprecatedServiceQueue { _ in
            printAction("🎉 queued call finished")
        })

		serviceQueue.collection(call: call, autoStart: true) { (resultFunction: () throws -> [Post]) in
			let posts = try? resultFunction()
			printAction("ServiceQueue Task 1 finished  \(posts?.count ?? -1)")
		}

		serviceQueue.collection(call: call, autoStart: true) { (resultFunction: () throws -> [Post]) in
			let posts = try? resultFunction()
			printAction("ServiceQueue Task 2 finished  \(posts?.count ?? -1)")
		}

		serviceQueue.collection(call: call, autoStart: true) { (resultFunction: () throws -> [Post]) in
			let posts = try? resultFunction()
			printAction("ServiceQueue Task 3 finished  \(posts?.count ?? -1)")
		}

        serviceQueue.resumeAll()
    }

}
