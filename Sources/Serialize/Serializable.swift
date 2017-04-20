import Foundation

/// Serializes any `Type` into json.
public protocol Serializable {

    var json: [String: Any] {get}

}

/// Serializes any `Type` into json.
public protocol JSONSerializable {

	var json: [String: Any] {get}

}
