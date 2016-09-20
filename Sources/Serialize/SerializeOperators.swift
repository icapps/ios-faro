import Foundation

/// MARK: - Serizalise operators
/// Will put a 'Type' into 'Any?' Type that can receive it.

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
