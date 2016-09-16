import Faro

// TODO: we should add a more generic parser

/// Example model
/// We inherit from NSObject to be useable in Objective-C
class Model: NSObject, Parseable {
    var value: String

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }
        value = json["key"]!
    }
    
    var JSON: [String: Any]? {
        return nil
    }
}
