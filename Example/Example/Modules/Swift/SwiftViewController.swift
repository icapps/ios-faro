import UIKit
import Faro
import Stella

class Posts: Parseable {

    required init?(from raw: Any) {
        
    }
    
    var JSON: [String: Any]? {
        return nil
    }

}

class SwiftViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let service = ExampleService()
        let call = Call(path: "posts")

        service.perform(call) { (result: Result<Posts>) in
            DispatchQueue.main.async {
                switch result {
                case .model(let model):
                    self.label.text = "Performed call for posts"
                    printBreadcrumb("\(model)")
                default:
                    printError("Could not perform call for posts")
                }
            }
        }
    }

}
