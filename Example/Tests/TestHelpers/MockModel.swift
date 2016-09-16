import Faro

class MockModel: Parseable {
    var uuid: String

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }

        do {
            uuid = try parseString("uuid", from: json)
        } catch {
            return nil
        }
    }
    
    var JSON: [String: Any]? {
        return nil
    }

    class func extractRootNode(from json: Any) -> JsonNode {
        if let jsonArray = json as? [Any] {
            return .rootNodes(jsonArray)
        }else if let json = json as? [String: Any] {
            return .rootNode(json)
        }else {
            return .rootNodeNotFound(json: json)
        }
    }

}
