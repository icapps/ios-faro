import Foundation

public func parse(_ callback: (_ json: inout [String: Any]) -> ()) -> [String: Any] {
    var json = [String: Any]()
    callback(&json)
    return json
}

public func parse <T>(_ named: String!, from: [String: Any]) throws -> T! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? T else {
            throw FaroError.emptyValue(key: named)
        }
        return value
    } else {
        throw FaroError.emptyKey
    }
}

public func parse(_ named: String!, from: [String: Any]) throws -> Date! {
    if let named = named , !named.isEmpty {
        if let value = from[named] as? TimeInterval {
            return Date(timeIntervalSince1970: value)
        } else if from[named] is String && DateParser.shared.dateFormat.characters.count > 0 {
            return DateParser.shared.dateFormatter.date(from: from[named] as! String)
        }
        throw FaroError.emptyValue(key: named)
    } else {
        throw FaroError.emptyKey
    }
}

public func parse<T>(from: Any) throws -> T? where T: Deserializable {

    guard let json = from as? [String: Any] else {
        throw FaroError.emptyCollection

    }

    guard let model = T(from: json) else {
        throw FaroError.emptyCollection
    }

    return model
}

public func parse<T>(from: Any) throws -> [T]? where T: Deserializable {
    if from is [[String: Any]] {
        guard let rawObjects = from as? [[String: Any]] else {
            throw FaroError.emptyCollection
        }
        return rawObjects.flatMap { T(from: $0) }
    } else {
        return nil
    }
}
