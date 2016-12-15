import UIKit
import Faro
import Stella

class PostViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let service = ExampleService()
        let call = Call(path: "posts")

        service.perform(call) { (result: Result<Post>) in
            DispatchQueue.main.async {
                switch result {
                case .models(let models):
                    self.label.text = "Performed call for posts"
                    printBreadcrumb("\(models!.map {"\($0.uuid): \($0.title!)"})")
                default:
                    printError("Could not perform call for posts")
                }
            }
        }

        let serviceQueue = ExampleServiceQueue { _ in
            printBreadcrumb("🎉 queued call finished")
        }

        serviceQueue.perform(call, autoStart: false) { (result: Result<Post>) in
            printBreadcrumb("Task 1 finished  \(result)")
        }

        serviceQueue.perform(call, autoStart: false) { (result: Result<Post>) in
            printBreadcrumb("Task 2 finished  \(result)")
        }

        serviceQueue.perform(call, autoStart: false) { (result: Result<Post>) in
            printBreadcrumb("Task 3 finished \(result)")
        }

        serviceQueue.resumeAll()
    }

}
