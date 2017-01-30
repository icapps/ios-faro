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

public func create <T>(_ named: String, from json: [String: Any]) throws -> T! {
	if !named.isEmpty {
		guard let value = json[named] as? T else {
			throw FaroError.emptyValue(key: named)
		}
		return value
	} else {
		throw FaroError.emptyKey
	}
}

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

public func create<T: Deserializable>(_ named: String, from json: [String: Any]) throws -> T {
	guard let jsonForKey = json[named] as? [String: Any] else {
		throw FaroError.emptyCollection(key: named, json: json)
	}
	guard let model = T(from: jsonForKey) else {
		throw FaroError.emptyCollection(key: named, json: json)
	}
	return model
}

public func create<T: Deserializable>(_ named: String, from json: [String: Any]) throws -> [T] {
	if let json = json[named]  as? [[String: Any]] {
		return json.flatMap { T(from: $0) }
	} else {
		throw FaroError.emptyCollection(key: named, json: json)
	}
}

