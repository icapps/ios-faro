import Faro

class MockModel: Decodable {
    var uuid: String?
}

extension MockModel: Updatable {
    func update(_ model: AnyObject) throws {
        guard let model = model as? MockModel else {
            return
        }
        uuid = model.uuid
    }

    func update(array: [AnyObject]) throws {
        guard let array = array as? [MockModel] else {
            return
        }
        let set = Set(array)
        guard let model = (set.first {$0 == self}) else {
            return
        }
        try update(model)
    }

    var hashValue: Int {
        return uuid?.hashValue ?? 0
    }

    static func == (lhs: MockModel, rhs: MockModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}
