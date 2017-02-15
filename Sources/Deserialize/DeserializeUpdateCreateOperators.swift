import Foundation

// MARK: - Deserializable objects
// Objects are always updated or created.

/// The operator we define assings a value. Therefore its Precendencegroup is AssignmentPrecedence.
/// Used for optional properties
infix operator |<: AssignmentPrecedence

// MARK: - Instantiates or Updates

/// Creates or updates a deserializable instance. If `lhs` is nil it creates, if not it updates
public func |< <P>(lhs: inout P?, rhs: Any?) throws where P: Deserializable & Updatable {
	guard let dict = rhs as? [String: Any] else {
		lhs = nil
		return
	}
	if let lhs = lhs {
		try lhs.update(from: dict)
	} else {
		lhs = P(from: dict)
	}
}

// MARK: - Array relations

/// Creates or updates a deserializable instance. If `lhs` is nil it creates, if not it updates
/// In the json the lhs is looked up via the link you provide by implementing `Linkable`
/// Three cases are supported
/// 1. If lhs is not nil and not found in rhs it is removed
/// 2. If lhs is found in rhs it is updated
/// 3. If rhs countains element not found in lhs it is created.
public func |< <P>(lhs: inout [P]?, rhs: Any?) throws where P: Deserializable & Updatable & Linkable, P.ValueType: Equatable {
	guard let rawObjects = rhs as? [[String: Any]] else {
		lhs = nil
		return
	}
	if var lhs = lhs, !lhs.isEmpty {
		try lhs.enumerated().forEach {
			let element = $0.element
			let dict = rawObjects.filter {($0[element.link.key] as? P.ValueType)  == element.link.value}
			if !dict.isEmpty {
				try element.update(from: dict)
			} else {
				lhs.remove(at: $0.offset)
			}
		}
	} else {
		lhs = rawObjects.flatMap { P(from: $0) }
	}
}

// MARK: - Required

/// Creates or updates a deserializable instance. If `lhs` is nil it creates, if not it updates
/// In the json the lhs is looked up via the link you provide by implementing `Linkable`
/// Three cases are supported
/// 1. If lhs is not nil and not found in rhs it is removed
/// 2. If lhs is found in rhs it is updated
/// 3. If rhs countains element not found in lhs it is created.
public func |< <P>(lhs: inout P, rhs: Any?) throws where P: Deserializable & Updatable {
	guard let dict = rhs as? [String: Any] else {
		throw FaroDeserializableError.deserializableMissing(lhs: lhs, rhs: rhs)
	}
	try lhs.update(from: dict)
}


/// Removes `Linkable.link.key` elements not found in rhs
/// ValueType of `Linkable.link.Value` is `Int`
public func |< <P>(lhs: inout [P], rhs: Any?) throws where P: Deserializable & Updatable & Linkable & Hashable, P.ValueType: Equatable {
	guard var nodesToProcess = rhs as? [[String: Any]] else {
		throw FaroDeserializableError.deserializableMissing(lhs: lhs, rhs: rhs)
	}
	if !lhs.isEmpty {
		var elementsToRemove = Set<P>()
		try lhs.enumerated().forEach {
			let element = $0.element

			let filterFunction: ([String: Any]) -> Bool = {($0[element.link.key] as? P.ValueType)  == element.link.value}
			let dict = nodesToProcess.filter(filterFunction)

			guard !dict.isEmpty, let index = nodesToProcess.index(where: filterFunction) else {
				elementsToRemove.insert($0.element)
				return
			}
			guard dict.count == 1, let elementJSON = dict.first else {
				throw FaroDeserializableError.linkNotUniqueInJSON(nodesToProcess, linkValue: "\(element.link.value)")
			}

			try element.update(from: elementJSON)
			// remove all nodes we processed
			nodesToProcess.remove(at: index)
		}

		lhs = lhs.filter {!elementsToRemove.contains($0)}
		// If we still have nodes to process. Add them.
		nodesToProcess.forEach {
			if let model = P(from: $0) {
				lhs.append(model)
			}
		}

	} else {
		lhs = nodesToProcess.flatMap { P(from: $0) }
	}

}

// MARK: - Set Relation

/// Removes `Linkable.link.key` elements not found in rhs
/// ValueType of `Linkable.link.Value` is `Int`
public func |< <P>(lhs: inout Set<P>, rhs: Any?) throws where P: Deserializable & Updatable & Linkable, P.ValueType: Equatable {
	guard var nodesToProcess = rhs as? [[String: Any]] else {
		throw FaroDeserializableError.deserializableMissing(lhs: lhs, rhs: rhs)
	}
	if !lhs.isEmpty {
		try lhs.enumerated().forEach {
			let element = $0.element

			let filterFunction: ([String: Any]) -> Bool = {($0[element.link.key] as? P.ValueType)  == element.link.value}
			let dict = nodesToProcess.filter(filterFunction)

			guard let first = dict.first, let index = nodesToProcess.index(where: filterFunction) else {
				lhs.remove($0.element)
				return
			}
			guard dict.count == 1 else {
				throw FaroDeserializableError.linkNotUniqueInJSON(nodesToProcess, linkValue: "\(element.link.value)")
			}

			try element.update(from: first)
			// remove all nodes we processed
			nodesToProcess.remove(at: index)
		}

		// If we still have nodes to process. Add them.
		nodesToProcess.forEach {
			if let model = P(from: $0) {
				lhs.insert(model)
			}
		}

	} else {
		lhs = Set<P>(nodesToProcess.flatMap { P(from: $0) })
	}

}

// MARK: - Primitive Types

/// `Any?` is taken and set to the left hand side.
public func |< (lhs: inout Int?, rhs: Any?) {
	lhs = rhs as? Int
}

public func |< (lhs: inout Double?, rhs: Any?) {
	lhs = rhs as? Double
}

public func |< (lhs: inout Bool?, rhs: Any?) {
	lhs = rhs as? Bool
}

public func |< (lhs: inout String?, rhs: Any?) {
	lhs = rhs as? String
}

public func |< (lhs: inout Date?, rhs: TimeInterval?) {
	guard let timeInterval = rhs else {
		return
	}

	lhs = Date(timeIntervalSince1970: timeInterval)
}

public func |< (lhs: inout Date?, rhs: (Any?, String)) {
	guard let date = rhs.0 as? String else {
		return
	}

	DateParser.shared.dateFormat = rhs.1
	lhs = DateParser.shared.dateFormatter.date(from: date)
}

// MARK: - Required

public func |< (lhs: inout Int, rhs: Any?) throws {
	guard let value = rhs as? Int else {
		throw FaroDeserializableError.intMissing(rhs: lhs, lhs: rhs)
	}
	lhs = value
}

public func |< (lhs: inout Double, rhs: Any?) throws {
	guard let value = rhs as? Double else {
		throw FaroDeserializableError.doubleMissing(lhs: lhs, rhs: rhs)
	}
	lhs = value
}

public func |< (lhs: inout Bool, rhs: Any?) throws {
	guard let value = rhs as? Bool else {
		throw FaroDeserializableError.boolMissing(lhs: lhs, rhs: rhs)
	}
	lhs = value
}

public func |< (lhs: inout String, rhs: Any?) throws {
	guard let value = rhs as? String else {
		throw FaroDeserializableError.stringMissing(lhs: lhs, rhs: rhs)
	}
	lhs = value
}

public func |< (lhs: inout Date, rhs: TimeInterval?) throws {
	guard let timeInterval = rhs else {
		throw FaroDeserializableError.dateMissing(lhs: lhs, rhs: rhs)
	}

	lhs = Date(timeIntervalSince1970: timeInterval)
}

public func |< (lhs: inout Date, rhs: (Any?, String)) throws {
	guard let date = rhs.0 as? String else {
		throw FaroDeserializableError.dateMissing(lhs: lhs, rhs: rhs)
	}

	DateParser.shared.dateFormat = rhs.1
	guard let createdDate = DateParser.shared.dateFormatter.date(from: date) else {
		throw FaroDeserializableError.invalidDate(date)
	}

	lhs = createdDate
}

// MARK: - RawRepresentable Types

// MARK: - String

// MARK: - Required

public func |< <T> (lhs: inout T, rhs: Any?) throws where T: RawRepresentable, T.RawValue == String {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		throw FaroDeserializableError.rawRepresentableMissing(lhs: lhs, rhs: rhs)
	}
	lhs = value
}

// MARK: - Optional

public func |< <T> (lhs: inout T?, rhs: Any?) where T: RawRepresentable, T.RawValue == String {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		lhs = nil
		return
	}
	lhs = value
}

// MARK: - Int

// MARK: - Required

public func |< <T> (lhs: inout T, rhs: Any?) throws where T: RawRepresentable, T.RawValue == Int {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		throw FaroDeserializableError.rawRepresentableMissing(lhs: lhs, rhs: rhs)
	}
	lhs = value
}

// MARK: - Optional

public func |< <T> (lhs: inout T?, rhs: Any?) where T: RawRepresentable, T.RawValue == Int {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		lhs = nil
		return
	}
	lhs = value
}


