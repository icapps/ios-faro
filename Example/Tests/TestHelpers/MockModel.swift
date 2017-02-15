import Faro

class MockModel: Deserializable {
    var uuid: String?

    required init?(from raw: Any) {
        do {
            try update(from: raw)
        } catch {
            return nil
        }
    }

}

extension MockModel: Updatable {

    func update(from raw: Any) throws {
        guard let json = raw as? [String: Any] else {
            throw FaroError.updateNotPossible(json: raw, model: self)
        }
        self.uuid |< json["uuid"]
    }

}
