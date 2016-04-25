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
	*/
	public func transform<Type: Parsable>(data: NSData, body: Type? = nil, completion:(Type)->()) throws {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if var model = body {
                model.importFromJSON(json)
                completion(model)
            }
            else {
                completion(Type(json: json))
            }
        }
        catch {
            throw TransformError.JSONError
        }
	}

	public func type () -> TransformType {
		return .JSON
	}

	/**
	* TODO: #5 transformation of array results to existing objects.

	- parameter data: valid JSON
    - parameter rootKey: root of the array. Defaults to 'results', but can be overridden to a custom value
	- returns: via the completion block an array of parsed objects of `Type`.
	*/

    public func transform<Type: Parsable>(data: NSData, completion:([Type])->()) throws{
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let rootKey = Type.rootKey(), let array = json[rootKey] as? [[String:AnyObject]] {
				completion(dictToArray(array))
            }
            else if let dict = json as? [String:AnyObject] {
                let model = Type(json: dict)
                completion([model])
			}else if let array = json as? [[String:AnyObject]] {
				completion(dictToArray(array))
			}
            else {
                throw TransformError.InvalidObject
            }
        }
        catch {
            throw TransformError.JSONError
        }
	}

	private func dictToArray<Type: Parsable>(array: [[String:AnyObject]]) -> [Type] {
		var concreteObjectArray = [Type]()
		for dict in array {
			concreteObjectArray.append(Type(json: dict))
		}
		return concreteObjectArray
	}
}
