import UIKit
import Faro

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!

	/// !! It is important to retain the service until you have a result.

	let failingService = Service<Post>(call: Call(path: "bullshit"), deprecatedService:ExampleDeprecatedService())
	let service = Service<Post>(call: Call(path: "posts"), deprecatedService:ExampleDeprecatedService())

    override func viewDidLoad() {
        super.viewDidLoad()

		service.collection { [weak self] (resultFunction) in
			DispatchQueue.main.async {
				do {
					let posts = try resultFunction()
					self?.label.text = "Performed call for posts"
                    print("Service \(posts.map {"\($0.uuid): \($0.title ?? "")"}.reduce("") {"\($0)\n\($1)"})")
				} catch {
                    print(error)
				}
			}
		}

		// Test service queue

        let serviceQueue = ServiceQueue(deprecatedServiceQueue: ExampleDeprecatedServiceQueue { (failedTaks) in
            print("🎉 queued call finished with failedTasks \(String(describing: failedTaks)))")
        })

		let call = Call(path: "posts")
		serviceQueue.collection(call: call, autoStart: true) { (resultFunction: () throws -> [Post]) in
			let posts = try? resultFunction()
            print("ServiceQueue Task 1 finished  \(posts?.count ?? -1)")
		}

		serviceQueue.collection(call: call, autoStart: true) { (resultFunction: () throws -> [Post]) in
			let posts = try? resultFunction()
            print("ServiceQueue Task 2 finished  \(posts?.count ?? -1)")
		}

		serviceQueue.collection(call: call, autoStart: true) { (resultFunction: () throws -> [Post]) in
			let posts = try? resultFunction()
            print("ServiceQueue Task 3 finished  \(posts?.count ?? -1)")
		}

        serviceQueue.resumeAll()

		// Test failure

		failingService.single {  _ in
			// should have printed failure
		}

		failingService.collection {  _ in
			// should have printed failure
		}
    }

}
