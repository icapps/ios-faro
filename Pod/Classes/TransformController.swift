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
	- parameter data: Valid JSON
    - parameter inputModel: Optional input object of `Type`. If no input object is provided, a new object of `Type` is created based on the JSON.
     If an existing object of `Type` is passed, the object properties are filled in based on the JSON.
	- returns: Via the completion block a parsed object of `Type` is returned.
	- throws:
	*/
	public func transform<Rivet: protocol<Parsable, Mitigatable>>(data: NSData, entity: Rivet? = nil, succeed:(Rivet)->()) throws {

		var model = entity
		if entity == nil {
			model = Rivet()
		}

		let mitigator = model!.responseMitigator()
		let json =  try getJSONFromData(data, rootKey: Rivet.rootKey(), mitigator: mitigator)

		do {
			try model!.parseFromDict(json)
			succeed(model!)
		}catch ResponseError.InvalidDictionary(dictionary: let dict) {
			if let correctedDictionary = try mitigator.responseInvalidDictionary(dict) {
				try model!.parseFromDict(correctedDictionary)
			}
			succeed(model!)
		}catch {
			throw error
		}
	}

	public func type () -> TransformType {
		return .JSON
	}

	/**
	- parameter data: Valid JSON
    - parameter rootKey: Root of the array. Defaults to 'results', but can be overridden to a custom value
	- returns: Via the completion block an array of parsed objects of `Type`.
	- throws:
	*/
    public func transform<Rivet: protocol<Parsable, Mitigatable>>(data: NSData, entity: Rivet? = nil, succeed:([Rivet])->()) throws{

		var model = entity
		if entity == nil {
			model = Rivet()
		}

		let json = try getJSONFromData(data, rootKey: Rivet.rootKey(), mitigator: model!.responseMitigator())

		if let array = json as? [[String:AnyObject]] {
			succeed(try dictToArray(array))
		}else if let dict = json as? [String:AnyObject] {
			let model = Rivet()
			try model.parseFromDict(dict)
			succeed([model])
		}else if let array = json as? [[String:AnyObject]] {
			succeed(try dictToArray(array))
		}
		else {
			throw ResponseError.InvalidDictionary(dictionary: json)
		}
	}

	private func getJSONFromData(data: NSData, rootKey: String?, mitigator: ResponseMitigatable) throws -> AnyObject {

		var json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)

		if let
			rootKey = rootKey,
			jsonWithoutRoot = json[rootKey]{

			if jsonWithoutRoot == nil {
				if let correctedJson = try mitigator.responseInvalidDictionary(json) {
					json = correctedJson
				}else {
					throw ResponseError.InvalidDictionary(dictionary: json)
				}

			}else {
				json = jsonWithoutRoot!
			}
		}

		return json
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
