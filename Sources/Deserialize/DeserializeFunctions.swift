import Foundation

// MARK: - RawRepresentable Types

// MARK: - String

public func parse <T: RawRepresentable>(_ named: String, from: [String: Any]) throws -> T! where T.RawValue == String {
	if !named.isEmpty {
		guard let raw = from[named] as? T.RawValue, let value = T(rawValue:raw) else {
			throw FaroDeserializableError.emptyValue(key: named)
		}
		return value
	} else {
		throw FaroDeserializableError.emptyKey
	}
}

// MARK: - Int

public func parse <T: RawRepresentable>(_ named: String, from: [String: Any]) throws -> T! where T.RawValue == Int {
	if !named.isEmpty {
		guard let raw = from[named] as? T.RawValue, let value = T(rawValue:raw) else {
			throw FaroDeserializableError.emptyValue(key: named)
		}
		return value
	} else {
		throw FaroDeserializableError.emptyKey
	}
}

// MARK: - Any Type

public func parse <T>(_ named: String, from: [String: Any]) throws -> T! {
	if !named.isEmpty {
		guard let value = from[named] as? T else {
			throw FaroError.emptyValue(key: named)
		}
		return value
	} else {
		throw FaroError.emptyKey
	}
}

public func parse(_ named: String, from: [String: Any], format: String) throws -> Date! {

	guard let dateAny = from[named] else {
		throw FaroDeserializableError.emptyValue(key: named)
	}

	DateParser.shared.dateFormat = format
	if !named.isEmpty {
		if let value = from[named] as? TimeInterval {
			return Date(timeIntervalSince1970: value)
		} else if from[named] is String && DateParser.shared.dateFormat.characters.count > 0 {
			return DateParser.shared.dateFormatter.date(from: from[named] as! String)
		} else {
			throw FaroDeserializableError.dateMissingWithKey(key: named, json: from)
		}
	} else {
		throw FaroDeserializableError.dateMissingWithKey(key: "", json: from)
	}
}

public func parse<T: Deserializable>(_ named: String, from: [String: Any]) throws -> T {
	guard let json = from[named] as? [String: Any] else {
		throw FaroError.emptyCollection(key: named, json: from)
	}
	guard let model = T(from: json) else {
		throw FaroError.emptyCollection(key: named, json: from)
	}
	return model
}

public func parse<T: Deserializable>(_ named: String, from: [String: Any]) throws -> [T] {
	if let json = from[named]  as? [[String: Any]] {
		return json.flatMap { T(from: $0) }
	} else {
		throw FaroError.emptyCollection(key: named, json: from)
	}
}

