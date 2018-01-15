//
//  DecodableMock.swift
//  Faro_Tests
//
//  Created by Stijn Willems on 15/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Faro

class DecodableMock: Decodable, Hashable, Updatable {

    var uuid: String

    enum UuidError: Error {
        case updateError
    }
    // MARK: - Hashable
    var hashValue: Int {return uuid.hashValue}
    static func == (lhs: DecodableMock, rhs: DecodableMock) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func update(_ model: AnyObject) throws {
        guard let model = model as? DecodableMock else {
            throw DecodableMock.UuidError.updateError
        }
        uuid = model.uuid
    }

    func update(array: [AnyObject]) throws {
        guard let array = array as? [DecodableMock] else {
            throw DecodableMock.UuidError.updateError
        }

        let set = Set(array)

        guard let model = (set.first {$0 == self}) else {
            return
        }
        try update(model)
    }
}
