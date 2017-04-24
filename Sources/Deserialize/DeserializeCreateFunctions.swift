import Foundation

// MARK: - RawRepresentable Types

// Use these to create new instances

// MARK: String

public func create <T: RawRepresentable>(_ named: String, from json: [String: Any]) throws -> T! where T.RawValue == String {
	if !named.isEmpty {
		guard let jsonKey = json[named] as? T.RawValue else {
			throw FaroDeserializableError.rawRepresentableMissingWithKey(key: named, json: json)
		}
		guard let value = T(rawValue:jsonKey) else {
			throw FaroDeserializableError.rawRepresentableWrongValue(key: named, value: jsonKey)
		}
		return value
	} else {
		throw FaroDeserializableError.emptyValue(key: named)
	}
}

// MARK: - Int

public func create <T: RawRepresentable>(_ named: String, from json: [String: Any]) throws -> T! where T.RawValue == Int {
	if !named.isEmpty {
		guard let jsonKey = json[named] as? T.RawValue else {
			throw FaroDeserializableError.rawRepresentableMissingWithKey(key: named, json: json)
		}
		guard let value = T(rawValue:jsonKey) else {
			throw FaroDeserializableError.rawRepresentableWrongValue(key: named, value: jsonKey)
		}
		return value
	} else {
		throw FaroDeserializableError.emptyValue(key: named)
	}
}

// MARK: - Any Type

/// Will instantiate a value of type T OR try to parse it as a date from a TimeIntervalSince1970.
/// If you want to parse a date with another format use the date functions with a format string.
public func create <T>(_ named: String, from json: [String: Any]) throws -> T! {
	if !named.isEmpty {
		guard let value = json[named] as? T else {
			do {
				return try create(named, from: json, format: "") as! T
			} catch {
				throw FaroDeserializableError.emptyValue(key: named)
			}
		}
		return value
	} else {
		throw FaroDeserializableError.emptyKey
	}
}

// MARK: - Date

public func create(_ named: String, from json: [String: Any], format: String) throws -> Date! {

	guard json[named] != nil else {
		throw FaroDeserializableError.emptyValue(key: named)
	}

	DateParser.shared.dateFormat = format
	if !named.isEmpty {
		if let value = json[named] as? TimeInterval {
			return Date(timeIntervalSince1970: value)
		} else if json[named] is String && DateParser.shared.dateFormat.characters.count > 0 {
			return DateParser.shared.dateFormatter.date(from: json[named] as! String)
		} else {
			throw FaroDeserializableError.dateMissingWithKey(key: named, json: json)
		}
	} else {
		throw FaroDeserializableError.dateMissingWithKey(key: "", json: json)
	}
}

// MARK: - Deserializable Type

public func create<T: JSONDeserializable>(_ named: String, from json: [String: Any]) throws -> T {
	guard let jsonForKey = json[named] as? [String: Any] else {
		throw FaroDeserializableError.emptyCollection(key: named, json: json)
	}
	
	return try T(jsonForKey)
}

// MARK: - Array

public func create<T: JSONDeserializable>(_ named: String, from json: [String: Any]) throws -> [T] {
	if let json = json[named]  as? [[String: Any]] {
		return try json.flatMap { try T($0) }
	} else {
		throw FaroDeserializableError.emptyCollection(key: named, json: json)
	}
}

// MARK: - Set

public func create<T: JSONDeserializable>(_ named: String, from json: [String: Any]) throws -> Set<T> {
	if let json = json[named]  as? [[String: Any]] {
		return Set<T>(try json.map { try T($0) })
	} else {
		throw FaroDeserializableError.emptyCollection(key: named, json: json)
	}
}
