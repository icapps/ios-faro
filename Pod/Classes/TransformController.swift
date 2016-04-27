import Foundation

public enum TransformType: String {
	case JSON = "json"
}

/**
Transformations of data to concrete objects. This implementation expects data to be valid JSON.
*/
public class TransformController {

	public init() {
	}
	/**
	- parameter data: valid JSON
    - parameter inputModel: optional input object of `Type`. If no input object is provided, a new object of `Type` is created based on the JSON.
     If an existing object of `Type` is passed, the object properties are filled in based on the JSON.
	- returns: via the completion block a parsed object of `Type` is returned.
	- throws:
	*/
	public func transform<Type: Parsable>(data: NSData, entity: Type? = nil, succeed:(Type)->()) throws {
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		if var model = entity {
			try model.parseFromDict(json)
			succeed(model)
		}
		else {
			let model = Type()
			try model.parseFromDict(json)
			succeed(model)
		}
	}

	public func type () -> TransformType {
		return .JSON
	}

	/**
	- parameter data: valid JSON
    - parameter rootKey: root of the array. Defaults to 'results', but can be overridden to a custom value
	- returns: via the completion block an array of parsed objects of `Type`.
	- throws:
	*/

    public func transform<Type: Parsable>(data: NSData, entity: Type? = nil, succeed:([Type])->()) throws{
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		if let rootKey = Type.rootKey(), let array = json[rootKey] as? [[String:AnyObject]] {
			succeed(try dictToArray(array))
		}
		else if let dict = json as? [String:AnyObject] {
			let model = Type()
			try model.parseFromDict(dict)
			succeed([model])
		}else if let array = json as? [[String:AnyObject]] {
			succeed(try dictToArray(array))
		}
		else {
			throw ResponseError.InvalidDictionary(dictionary: json)
		}
	}

	private func dictToArray<Type: Parsable>(array: [[String:AnyObject]]) throws -> [Type] {
		var concreteObjectArray = [Type]()
		for dict in array {
			let entity = Type()
			try entity.parseFromDict(dict)
			concreteObjectArray.append(entity)
		}
		return concreteObjectArray
	}
}
