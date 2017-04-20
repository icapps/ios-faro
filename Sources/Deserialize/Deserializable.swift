import Foundation

/// Sets data on a class `Type`.
public protocol Deserializable {

	/// To initialize you can use the `DeserializeCreateFunctions`
	/// You should return nil if `raw` contain not all required keys to instantiate.
	init?(from raw: Any)

}

/// Sets data on a class `Type`.
public protocol JSONDeserializable {

	/// To initialize you can use the `DeserializeCreateFunctions`
	/// You should return nil if `raw` contain not all required keys to instantiate.
	init(_ raw: [String : Any]) throws

}
public protocol JSONUpdatable: class {

	/// To update you can use the `DeserializeUpdateCreateOperators`
	/// The operators make sure you update the memory location of an existing instance rather the asigning a different location in memory.
	func update(_ raw: [String: Any]) throws

}

public protocol Updatable: class {

	/// To update you can use the `DeserializeUpdateCreateOperators`
	/// The operators make sure you update the memory location of an existing instance rather the asigning a different location in memory.
	func update(from raw: Any) throws

}

/// Impliment to perform deserialization on linked object via the value of key.
public protocol Linkable: class {
	associatedtype ValueType

	var link: (key: String, value: ValueType) {get}
}
