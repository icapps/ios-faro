import Faro

// TODO: we should add a more generic parser

/// Example model
/// We inherit from NSObject to be useable in Objective-C
class Model: NSObject, Mappable {
    var value: String

    required init(json: Any) {
        if let json = json as? [String: String] {
            value = json["key"]!
        }else {
            value = ""
        }
    }
}
