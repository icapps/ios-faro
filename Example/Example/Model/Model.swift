
import Faro

/// Example model
/// TODO: we should add a more generic parser
/// We inherit from NSObject to be useable in Objective-C
class Model : NSObject, Mappable {
    var value : String

    required init(json: AnyObject) {
        if let json = json as? [String : String] {
            value = json["key"]!
        }else {
            value = ""
        }
    }
}