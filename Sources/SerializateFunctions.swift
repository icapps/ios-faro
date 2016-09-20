import Foundation

/// MARK: - Serizalise functions

public func parse(_ callback: (_ json: inout [String: Any]) -> ()) -> [String: Any] {
    var json = [String: Any]()
    callback(&json)
    return json
}

public func parseString(_ named: String!, from: [String: Any]) throws -> String! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? String else {
            throw ParseError.emptyValue(key: named)
        }
        return value
    } else {
        throw ParseError.emptyKey
    }
}

public func parseInt(_ named: String!, from: [String: Any]) throws -> Int! {
    if let named = named , !named.isEmpty {
        guard let value = from[named]! as? Int else {
            throw ParseError.emptyValue(key: named)
        }
        return value
    } else {
        throw ParseError.emptyKey
    }
}

public func parseDouble(_ named: String!, from: [String: Any]) throws -> Double! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? Double else {
            throw ParseError.emptyValue(key: named)
        }
        return value
    } else {
        throw ParseError.emptyKey
    }
}

public func parseBool(_ named: String!, from: [String: Any]) throws -> Bool! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? Bool else {
            throw ParseError.emptyValue(key: named)
        }
        return value
    } else {
        throw ParseError.emptyKey
    }
}

public func parseDate(_ named: String!, from: [String: Any]) throws -> Date! {
    if let named = named , !named.isEmpty {
        if let value = from[named] as? TimeInterval {
            return Date(timeIntervalSince1970: value)
        } else if from[named] is String && DateParser.shared.dateFormat.characters.count > 0 {
            return DateParser.shared.dateFormatter.date(from: from[named] as! String)
        }
        throw ParseError.emptyValue(key: named)
    } else {
        throw ParseError.emptyKey
    }
}

public func parseObject<T>(from: Any, ofType: T.Type) throws -> Deserializable? where T: Deserializable {
    if from is [String: Any] {
        return T(from: from as! [String: Any])!
    } else {
        return nil
    }
}

public func parseObjects<T>(from: Any, ofType: T.Type) throws -> [Deserializable]? where T: Deserializable {
    if from is [[String: Any]] {
        guard let rawObjects = from as? [[String: Any]] else {
            throw ParseError.emptyCollection
        }
        return rawObjects.flatMap { T(from: $0) }
    } else {
        return nil
    }
}
