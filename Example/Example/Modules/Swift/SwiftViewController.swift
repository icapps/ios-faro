import UIKit
import Faro
import Stella

class Post: Deserializable {
    var uuid: String?

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any?] else {
            return nil
        }
       self.uuid <-> json["uuid"]
    }

}

class SwiftViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

//        let service = ExampleService()
//        let call = Call(path: "posts")
//
//        service.perform(call) { (result: Result<Post>) in
//            DispatchQueue.main.async {
//                switch result {
//                case .models(let models):
//                    self.label.text = "Performed call for posts"
//                    printBreadcrumb("\(models!)")
//                default:
//                    printFaroError("Could not perform call for posts")
//                }
//            }
//        }
    }

}
