import UIKit
import Faro
import Stella

class Posts: Mappable {

    required init(json: AnyObject) {

    }

}

class SwiftViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let service = ExampleService()
        let call = Call(path: "posts")

        service.perform(call, toModelResult: { (result: Result<Posts>) in
            dispatch_on_main {
                switch result {
                case .Model(let model):
                    self.label.text = "fetched posts"
                    print("🎉 \(model)")
                default:
                    print("💣 fail")
                }
            }
        })
    }

}
