import UIKit
import Faro
import Stella

class Post: Deserializable {
    let uuid: Int
    var title: String?

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any] else {
            return nil
        }
        do {
            self.uuid = try parse("id", from: json)
        } catch {
            printError("Error parsing Post with \(error).")
            return nil
        }

        // Not required variables

        title <-> json["title"]
    }

}

class SwiftViewController: UIViewController {
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
                    printBreadcrumb("\(models!.map{"\($0.uuid): \($0.title!)"})")
                default:
                    printError("Could not perform call for posts")
                }
            }
        }

        let serviceQueue = ExampleServiceQueue() {
            printBreadcrumb("🎉 queued call finished")
        }

        let fail: (FaroError) -> () = { error in
            printError("An error happed: \(error)")
        }

        serviceQueue.performCollection(call, autoStart: false, fail: fail) { (model: [Post]) in
            printBreadcrumb("Task 1 finished")
        }

        serviceQueue.performCollection(call, autoStart: false, fail: fail) { (model: [Post]) in
            printBreadcrumb("Task 2 finished")
        }

        serviceQueue.performCollection(call, autoStart: false, fail: fail) { (model: [Post]) in
            printBreadcrumb("Task 3 finished")
        }

        serviceQueue.resumeAll()
    }

}
