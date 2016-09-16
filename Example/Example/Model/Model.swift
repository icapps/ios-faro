import Faro

/// Example model
class Model: Parseable {
    var uuid: String

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }
        uuid = json["uuid"]!
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
