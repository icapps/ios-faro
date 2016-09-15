import Foundation

public protocol Parseable {

    init?(from raw: [String: Any])

    var JSON: [String: Any]? { get }
}

// MARK: Parse from model

extension Parseable {

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
    
    public func parseObject<T>(from: Any, ofType: T.Type) throws -> Parseable? where T: Parseable {
        if from is [String: Any] {
            return T(from: from as! [String: Any])!
        } else {
            return nil
        }
    }
    
    public func parseObjects<T>(from: Any, ofType: T.Type) throws -> [Parseable]? where T: Parseable {
        if from is [[String: Any]] {
            guard let rawObjects = from as? [[String: Any]] else {
                throw ParseError.emptyCollection
            }
            return rawObjects.flatMap { T(from: $0) }
        } else {
            return nil
        }
    }
    
}

infix operator << { associativity left }

// MARK: Parse from model

public func << (lhs: inout Any?, rhs: String?) {
    lhs = rhs
}

public func << (lhs: inout Any?, rhs: Int?) {
    lhs = rhs
}

public func << (lhs: inout Any?, rhs: Bool?) {
    lhs = rhs
}

public func << (lhs: inout Any?, rhs: Double?) {
    lhs = rhs
}

public func << (lhs: inout Any?, rhs: Date?) {
    if let rhs = rhs {
        lhs = rhs.timeIntervalSince1970
    }
}

public func << <P>(lhs: inout P?, rhs: Any?) where P: Parseable {
    guard let dict = rhs as? [String: Any] else {
        lhs = nil
        return
    }
    lhs = P(from: dict)!
}

public func << <P>(lhs: inout [P]?, rhs: Any?) where P: Parseable {
    guard let rawObjects = rhs as? [[String: Any]] else {
        lhs = nil
        return
    }
    lhs = rawObjects.flatMap { P(from: $0) }
}

// MARK: Parse to model

public func << (lhs: inout Int?, rhs: Any?) {
    lhs = rhs as? Int
}

public func << (lhs: inout Double?, rhs: Any?) {
    lhs = rhs as? Double
}

public func << (lhs: inout Bool?, rhs: Any?) {
    lhs = rhs as? Bool
}

public func << (lhs: inout String?, rhs: Any?) {
    lhs = rhs as? String
}

public func << (lhs: inout String, rhs: Any?) {
    lhs = rhs as! String
}

public func << (lhs: inout Date?, rhs: Any?) {
    if let rhs = rhs as? TimeInterval {
        lhs = Date(timeIntervalSince1970: rhs)
    } else if rhs is String && DateParser.shared.dateFormat.characters.count > 0 {
        lhs = DateParser.shared.dateFormatter.date(from: rhs as! String)
    }
}

public func << (lhs: inout Date?, rhs: (Any?, String)) {
    DateParser.shared.setFormat(rhs.1)
    lhs = DateParser.shared.dateFormatter.date(from: rhs.0 as! String)
}

public func << <P>(lhs: inout Any?, rhs: P?) where P: Parseable {
    lhs = rhs?.JSON
}

public func << <P>(lhs: inout Any?, rhs: [P]?) where P: Parseable {
    var array = [[String: Any]]()
    for parseable in rhs! {
        array.append(parseable.JSON!)
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

enum ParseError: Error {
    case emptyKey
    case emptyValue(key: String)
    case emptyCollection
}
