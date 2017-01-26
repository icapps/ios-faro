import Foundation

/// Sets data on a class `Type`.
public protocol Deserializable {

    init?(from raw: Any)

}

public protocol Updatable {

    func update(from raw: Any) throws

}

/// Impliment to perform deserialization on linked object via the value of key.
public protocol Linkable {
	associatedtype ValueType

	var link: (key: String, value: ValueType) {get}
}
