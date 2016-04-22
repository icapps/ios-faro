
import Foundation


/**
Transformations of data to concrete objects. This implementation expects data to be valid JSON.
*/
public class TransformController {

	/**
	- parameter data: valid JSON
	- returns: via the completion block a parsed object of `Type` is returned.
	*/
	public func objectDataToConcreteObject<Type: Parsable>(data: NSData, body: Type? = nil, completion:(Type)->()) throws{
		
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		if let body = body {
			body.importFromJSON(json)
			completion(body)
		}else {
			completion(Type(json: json))
		}
	}

	/**
	* TODO: #5 transformation of array results to existing objects.

	- parameter data: valid JSON
	- returns: via the completion block an array of parsed objects of `Type`.
	*/

	public func objectsDataToConcreteObjects<Type: Parsable>(data: NSData, completion:([Type])->()) throws{
		
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		
		if let array = json["results"] as? [NSDictionary] {
			var concreteObjectArray = [Type]()
			for dict in array {
				concreteObjectArray.append(Type(json: dict))
			}
			completion(concreteObjectArray)
		}
	}
}