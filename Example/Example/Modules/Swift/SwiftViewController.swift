import UIKit
import Faro
import Stella

class Post: Parseable {

    required init?(from raw: Any) {
        
    }
    
    var JSON: [String: Any]? {
        return nil
    }

    class func extractRootNode(from json: Any) -> JsonNode {
        if let jsonArray = json as? [[String: Any]] {
            return .rootNodes(jsonArray)
        }else if let json = json as? [String: Any] {
            return .rootNode(json)
        }else {
            return .rootNodeNotFound(json: json)
        }
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
