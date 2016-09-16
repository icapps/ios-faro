import Faro

class MockModel: Parseable {
    var value: String

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }

        do {
            value = try parseString("key", from: json)
        } catch {
            return nil
        }
    }
    
    var JSON: [String: Any]? {
        return nil
    }

}
