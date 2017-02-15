import Foundation

/// The operator we define assings a value. Therefore its Precendencegroup is AssignmentPrecedence.
/// Used for optional properties
infix operator <->: AssignmentPrecedence


public func <-> <P>(lhs: inout P?, rhs: Any?) where P: Deserializable {
    guard let dict = rhs as? [String: Any] else {
        lhs = nil
        return
    }
    lhs = P(from: dict)
}

public func <-> <P>(lhs: inout [P]?, rhs: Any?) where P: Deserializable {
    guard let rawObjects = rhs as? [[String: Any]] else {
        lhs = nil
        return
    }
    lhs = rawObjects.flatMap { P(from: $0) }
}

// MARK: - Deserialize operators

// MARK: - Primitive Types -  Single
public func <-> (lhs: inout Int?, rhs: Any?) {
    lhs = rhs as? Int
}

public func <-> (lhs: inout Double?, rhs: Any?) {
    lhs = rhs as? Double
}

public func <-> (lhs: inout Bool?, rhs: Any?) {
    lhs = rhs as? Bool
}

public func <-> (lhs: inout String?, rhs: Any?) {
    lhs = rhs as? String
}

public func <-> (lhs: inout Date?, rhs: TimeInterval?) {
    guard let timeInterval = rhs else {
        return
    }

    lhs = Date(timeIntervalSince1970: timeInterval)
}

public func <-> (lhs: inout Date?, rhs: (Any?, String)) {
    guard let date = rhs.0 as? String else {
        return
    }

    DateParser.shared.dateFormat = rhs.1
    lhs = DateParser.shared.dateFormatter.date(from: date)
}


// MARK: - Primitive Types -  Array
public func <-> (lhs: inout [Int]?, rhs: Any?) {
	lhs = rhs as? [Int]
}

public func <-> (lhs: inout [Double]?, rhs: Any?) {
	lhs = rhs as? [Double]
}

public func <-> (lhs: inout [Bool]?, rhs: Any?) {
	lhs = rhs as? [Bool]
}

public func <-> (lhs: inout [String]?, rhs: Any?) {
	lhs = rhs as? [String]
}

public func <-> (lhs: inout [Date]?, rhs: [TimeInterval]?) {
	guard let rhs = rhs else {
		lhs = nil
		return
	}
	lhs = [Date]()
	rhs.forEach { timeInterval in
		lhs?.append(Date(timeIntervalSince1970: timeInterval))
	}

}

public func <-> (lhs: inout [Date]?, rhs: [(Any?, String)]?) {
	guard let rhs = rhs else {
		lhs = nil
		return
	}

	lhs = [Date]()

	rhs.forEach { dateTuple in
		DateParser.shared.dateFormat = dateTuple.1
		if let dateString = dateTuple.0 as? String, let date = DateParser.shared.dateFormatter.date(from: dateString) {
			lhs?.append(date)
		}
	}

}
