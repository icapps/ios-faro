
import Foundation


//Transformations of data to concrete objects.

public class TransformController {
	
	public func objectDataToConcreteObject<ConcreteType: BaseModel>(data: NSData, body: ConcreteType? = nil, completion:(ConcreteType)->()) throws{
		
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		if let body = body {
			body.importFromJSON(json)
			completion(body)
		}else {
			completion(ConcreteType(json: json))
		}
	}
	
	//TODO: #5 transformation of array results to existing objects.
	public func objectsDataToConcreteObjects<ConcreteType: BaseModel>(data: NSData, completion:([ConcreteType])->()) throws{
		
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		
		if let array = json["results"] as? [NSDictionary] {
			var concreteObjectArray = [ConcreteType]()
			for dict in array {
				concreteObjectArray.append(ConcreteType(json: dict))
			}
			completion(concreteObjectArray)
		}
	}
}