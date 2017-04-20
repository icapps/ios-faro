import Faro

class MockModel: Deserializable, JSONDeserializable, JSONUpdatable {
    var uuid: String?

	required init(_ raw: [String: Any]) throws {
		try update(from: raw)
	}
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
            throw FaroDeserializableError.invalidJSON(model: self, json: raw)
        }
        self.uuid |< json["uuid"]
    }

	func update(_ raw: [String : Any]) throws {
		self.uuid |< raw["uuid"]
	}

}
