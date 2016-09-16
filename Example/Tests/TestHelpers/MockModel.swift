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

}
