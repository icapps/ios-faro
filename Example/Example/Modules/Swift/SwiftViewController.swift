import UIKit
import Faro
import Stella

class Post: Parseable {

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

        service.perform(call) { (result: Result<Post>) in
            DispatchQueue.main.async {
                switch result {
                case .models(let models):
                    self.label.text = "Performed call for posts"
                    printBreadcrumb("\(models)")
                default:
                    printError("Could not perform call for posts")
                }
            }
        }
    }

}
