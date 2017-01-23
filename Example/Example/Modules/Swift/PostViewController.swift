import UIKit
import Faro
import Stella

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!

	var posts: [Post]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let service = ExampleService()
        let call = Call(path: "posts")

		do {
			try service.perform(call, success: { (postsResult: Success<Post>) in
				self.posts = try postsResult.arrayModels()
				DispatchQueue.main.async {
					printBreadcrumb("\(self.posts?.map {"\($0.uuid): \($0.title)"})")
				}
			})

			let serviceQueue = ExampleServiceQueue { _ in
				printBreadcrumb("🎉 queued call finished")
			}

			try serviceQueue.perform(call, success: { (result: Success<Post>) in
				printBreadcrumb("Task 1 finished  \(result)")
			})

			try serviceQueue.perform(call, success: { (result: Success<Post>) in
				printBreadcrumb("Task 2 finished  \(result)")
			})

			try serviceQueue.perform(call, success: { (result: Success<Post>) in
				printBreadcrumb("Task 3 finished  \(result)")
			})

			serviceQueue.resumeAll()
		} catch {
			printError(error)
		}

    }

}
