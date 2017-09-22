import Foundation

/// MARK: - Serizalise operators
/// The operator we define assings a value. Therefore its Precendencegroup is AssignmentPrecedence.
/// Used for optional properties
infix operator <|: AssignmentPrecedence

/// Will put a 'Type' into 'Any?' Type that can receive it.
public func <| <P>(lhs: inout Any?, rhs: [P]?) where P: Serializable {
	guard let rhs = rhs else {
		return
	}
	var array = [[String: Any]]()
	for serializable in rhs {
		array.append(serializable.json)
	}
	lhs = array
}

public func <| <P>(lhs: inout Any?, rhs: P?) where P: Serializable {
	lhs = rhs?.json
}

/// Handy operators

public func <| (lhs: inout Any?, rhs: String?) {
	guard let rhs = rhs else {
		return
	}
	lhs = rhs
}

public func <| (lhs: inout Any?, rhs: Int?) {
	guard let rhs = rhs else {
		return
	}
	lhs = rhs
}

public func  <| (lhs: inout Any?, rhs: Bool?) {
	guard let rhs = rhs else {
		return
	}
	lhs = rhs
}

public func  <| (lhs: inout Any?, rhs: Double?) {
	guard let rhs = rhs else {
		return
	}
	lhs = rhs
}

public func  <| (lhs: inout Any?, rhs: Date?) {
	guard let rhs = rhs else {
		return
	}
	lhs = rhs.timeIntervalSince1970
}

// MARK: - Arrays

public func  <| (lhs: inout Any?, rhs: [String]?) {
	guard let rhs = rhs else {
		return
	}
	lhs = rhs
}

/// Serialize a date to the requested format as the string in the tupple
public func  <| (lhs: inout Any?, rhs: (Date?, String)) {
	guard let date = rhs.0 else {
		return
	}
	DateParser.shared.dateFormat = rhs.1
	lhs = DateParser.shared.dateFormatter.string(from: date)
}
