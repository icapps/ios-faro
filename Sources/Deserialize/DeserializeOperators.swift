import Foundation

/// The operator we define assings a value. Therefore its Precendencegroup is AssignmentPrecedence.
infix operator <-: AssignmentPrecedence

/// MARK: Deserialize operators
/// `Any?` is taken and set to the left hand side.

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
    DateParser.shared.dateFormat = rhs.1
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

