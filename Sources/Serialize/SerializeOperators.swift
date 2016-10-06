import Foundation

/// MARK: - Serizalise operators

/// Will put a 'Type' into 'Any?' Type that can receive it.
public func <-> <P>(lhs: inout Any?, rhs: [P]?) where P: Serializable {
    guard let rhs = rhs else {
        return
    }
    var array = [[String: Any]]()
    for serializable in rhs {
        array.append(serializable.json)
    }
    lhs = array
}

public func <-> <P>(lhs: inout Any?, rhs: P?) where P: Serializable {
    lhs = rhs?.json
}

/// Handy operators

public func <-> (lhs: inout Any?, rhs: String?) {
    lhs = rhs
}

public func <-> (lhs: inout Any?, rhs: Int?) {
    lhs = rhs
}

public func <-> (lhs: inout Any?, rhs: Bool?) {
    lhs = rhs
}

public func <-> (lhs: inout Any?, rhs: Double?) {
    lhs = rhs
}

public func <-> (lhs: inout Any?, rhs: Date?) {
    if let rhs = rhs {
        lhs = rhs.timeIntervalSince1970
    }
}

/// Serialize a date to the requested format as the string in the tupple
public func <-> (lhs: inout Any?, rhs: (Date?, String)) {
    guard let date = rhs.0 else {
        return
    }
    DateParser.shared.dateFormat = rhs.1
    lhs = DateParser.shared.dateFormatter.string(from: date)
}


