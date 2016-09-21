import Foundation

/// Sets data on a class `Type`.
/// Unfortunatally it has to be a class because functions are mutating.
public protocol Deserializable: class {

    init?(from raw: Any)

    /// Each object should return a function that accepts `Any?`.
    /// Than function is used to set it to the corresponding property
    var mappers: [String : ((Any?)->())] {get}

    /// Below is optional because implemented in extension
    /// You can override them to customise
    func map(from raw: Any)

    subscript(key: String) -> Any? {get set}

}

/// Serializes any `Type` into json.
public protocol Serializable {
    /// Get a json Dictionary back one level deep. Meaning we do not Parse relations.
    /// if you want your relations parsed implement `CustomSerializable`
    var json: [String: Any?] {get}

}

public protocol CustomSerializable: Serializable {
    /// - returns: if a given `propertyName` is a Relation (`Type` or `[Type]`)
    func isRelation(for propertyName: String) -> Bool
    /// - returns: the serialized json of a relation. 
    /// If single relation will be `[String: Any?]' else `[[String: Any?]]`
    func jsonForRelation(with key: String) -> JsonNode
}

// MARK: Extension Deserialize from model

/// This maps `Any` type to the properties on anyone who is `Deserializable`.
public extension Deserializable {
    /// Uses `Mirror` to lookup a list of properties on your `Type`
    public func map(from raw: Any)  {
        guard let json = raw as? [String: Any] else {
            return
        }

        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            self[child.label!] = json[child.label!]
        }
    }

    /// Makes sure a `Deserializable` kan be used as a supscript
    public subscript(key: String) -> Any? {
        get {
            if let serializableSelf = self as? Serializable {
                return serializableSelf.json[key]
            } else {
                return nil
            }
        } set {
            if let mapper = mappers[key] {
                mapper(newValue)
            }
        }
    }
    
}

//MARK: - Extension Serialize from model

public extension Serializable {
    /// Get a json Dictionary back one level deep. Meaning we do not Parse relations.
    /// if you want your relations parsed implement `CustomSerializable`
    public var json: [String: Any?] {
        get {
            if let customSelf = self as? CustomSerializable {
                var internalMap = [String: Any]()
                let mirror = Mirror(reflecting: self)
                for child in mirror.children where customSelf.isRelation(for: child.label!) == false{
                    internalMap[child.label!] = child.value
                }

                for child in mirror.children where customSelf.isRelation(for: child.label!) == true {
                    let relation = customSelf.jsonForRelation(with: child.label!)
                    switch relation {
                    case .nodeArray(let array):
                        internalMap[child.label!] = array
                    case .nodeObject(let object):
                        internalMap[child.label!] = object
                    default:
                        break
                    }
                }
                return internalMap
            } else {
                var internalMap = [String: Any]()
                let mirror = Mirror(reflecting: self)
                for child in mirror.children {
                    internalMap[child.label!] = child.value
                }
                return internalMap
            }
        }
    }

}

//MARK: - Utility functions

/// You can use this like in `DeserializableSpec` in the example project.
public func extractRelations<T: Deserializable>(from json: Any?) -> [T]? {
    guard let json = json as? [[String: Any]] else {
        return nil
    }
    var relations = [T]()
    for dict in json {
        if let foo = T(from: dict) {
            relations.append(foo)
        }
    }
    return relations
}

// MARK: - Parse from model

public func parse(_ callback: (_ json: inout [String: Any]) -> ()) -> [String: Any] {
    var json = [String: Any]()
    callback(&json)
    return json
}

public func setDateFormat(_ format: String) {
    DateParser.shared.setFormat(format)
}

public func parseString(_ named: String!, from: [String: Any]) throws -> String! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? String else {
            throw FaroError.emptyValue(key: named)
        }
        return value
    } else {
        throw FaroError.emptyKey
    }
}

public func parseInt(_ named: String!, from: [String: Any]) throws -> Int! {
    if let named = named , !named.isEmpty {
        guard let value = from[named]! as? Int else {
            throw FaroError.emptyValue(key: named)
        }
        return value
    } else {
        throw FaroError.emptyKey
    }
}

public func parseDouble(_ named: String!, from: [String: Any]) throws -> Double! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? Double else {
            throw FaroError.emptyValue(key: named)
        }
        return value
    } else {
        throw FaroError.emptyKey
    }
}

public func parseBool(_ named: String!, from: [String: Any]) throws -> Bool! {
    if let named = named , !named.isEmpty {
        guard let value = from[named] as? Bool else {
            throw FaroError.emptyValue(key: named)
        }
        return value
    } else {
        throw FaroError.emptyKey
    }
}

public func parseDate(_ named: String!, from: [String: Any]) throws -> Date! {
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
            throw FaroError.emptyCollection
        }
        return rawObjects.flatMap { T(from: $0) }
    } else {
        return nil
    }
}

/// The operator we define assings a value. Therefor its Precendencegroup is AssignmentPrecedence.
infix operator <-: AssignmentPrecedence

// MARK: Parse from model

public func <- (lhs: inout Any?, rhs: String?) {
    lhs = rhs
}

public func <- (lhs: inout Any?, rhs: Int?) {
    lhs = rhs
}

public func <- (lhs: inout Any?, rhs: Bool?) {
    lhs = rhs
}

public func <- (lhs: inout Any?, rhs: Double?) {
    lhs = rhs
}

public func <- (lhs: inout Any?, rhs: Date?) {
    if let rhs = rhs {
        lhs = rhs.timeIntervalSince1970
    }
}

public func <- <P>(lhs: inout P?, rhs: Any?) where P: Deserializable {
    guard let dict = rhs as? [String: Any] else {
        lhs = nil
        return
    }
    lhs = P(from: dict)!
}

public func <- <P>(lhs: inout [P]?, rhs: Any?) where P: Deserializable {
    guard let rawObjects = rhs as? [[String: Any]] else {
        lhs = nil
        return
    }
    lhs = rawObjects.flatMap { P(from: $0) }
}

// MARK: Parse to model

public func <- (lhs: inout Int?, rhs: Any?) {
    lhs = rhs as? Int
}

public func <- (lhs: inout Double?, rhs: Any?) {
    lhs = rhs as? Double
}

public func <- (lhs: inout Bool?, rhs: Any?) {
    lhs = rhs as? Bool
}

public func <- (lhs: inout String?, rhs: Any?) {
    lhs = rhs as? String
}

public func <- (lhs: inout String, rhs: Any?) {
    lhs = rhs as! String
}

public func <- (lhs: inout Date?, rhs: Any?) {
    if let rhs = rhs as? TimeInterval {
        lhs = Date(timeIntervalSince1970: rhs)
    } else if rhs is String && DateParser.shared.dateFormat.characters.count > 0 {
        lhs = DateParser.shared.dateFormatter.date(from: rhs as! String)
    }
}

public func <- (lhs: inout Date?, rhs: (Any?, String)) {
    DateParser.shared.setFormat(rhs.1)
    lhs = DateParser.shared.dateFormatter.date(from: rhs.0 as! String)
}

public func <- <P>(lhs: inout Any?, rhs: P?) where P: Serializable {
    lhs = rhs?.json
}

public func <- <P>(lhs: inout Any?, rhs: [P]?) where P: Serializable {
    var array = [[String: Any]]()
    for serializable in rhs! {
        array.append(serializable.json)
    }
    lhs = array
}

class DateParser: NSObject {
    static let shared = DateParser()
    let dateFormatter = DateFormatter()
    var dateFormat: String

    required override init() {
        dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }

    func setFormat(_ format: String) {
        if (dateFormat != format) {
            dateFormat = format
            self.dateFormatter.dateFormat = dateFormat
        }
    }
}

