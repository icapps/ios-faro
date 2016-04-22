import Foundation

public enum TransformError:ErrorType {
    case InvalidObject
    case JSONError
}

/**
Transformations of data to concrete objects. This implementation expects data to be valid JSON.
*/
public class TransformController {

	/**
	- parameter data: valid JSON
    - parameter inputModel: optional input object of `Type`. If no input object is provided, a new object of `Type` is created based on the JSON.
     If an existing object of `Type` is passed, the object properties are filled in based on the JSON.
	- returns: via the completion block a parsed object of `Type` is returned.
	*/
	public func objectDataToConcreteObject<Type: Parsable>(data: NSData, inputModel: Type? = nil, completion:(Type)->()) throws {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let model = inputModel {
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

	/**
	* TODO: #5 transformation of array results to existing objects.

	- parameter data: valid JSON
    - parameter rootKey: root of the array. Defaults to 'results', but can be overridden to a custom value
	- returns: via the completion block an array of parsed objects of `Type`.
	*/

    public func objectsDataToConcreteObjects<Type: Parsable>(data: NSData, rootKey: String = "results", completion:([Type])->()) throws{
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let array = json[rootKey] as? [[String:AnyObject]] {
                var concreteObjectArray = [Type]()
                for dict in array {
                    concreteObjectArray.append(Type(json: dict))
                }
                completion(concreteObjectArray)
            }
            else if let dict = json as? [String:AnyObject] {
                let model = Type(json: dict)
                completion([model])
            }
            else {
                throw TransformError.InvalidObject
            }
        }
        catch {
            throw TransformError.JSONError
        }
	}
}
