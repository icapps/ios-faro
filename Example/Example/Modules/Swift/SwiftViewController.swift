import UIKit
import Faro

class Foo: Mappable {

    required init(json: AnyObject) {

    }

}

class SwiftViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = Faro.Configuration(baseURL: "http://jsonplaceholder.typicode.com")
        let service = JSONService(configuration: configuration)
        let order = Order(path: "posts")

        service.serve(order) { (result: Result <Foo>) in
            switch result {
            case .JSON(let json):
                if let json = json as? [[String: AnyObject]] {
                    print("🎉 received \(json)")
                } else {
                }
            default:
                print("💣 fail")
            }
        }
    }

}
