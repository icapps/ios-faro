
import Foundation

/**
* The transformController has the task to handle transformations of data to concrete objects.
* All errors that could occur in the process should be handeled.
*/

public class TransfromController {
	
	public func objectDataToConcreteObject<ConcreteType: BaseModel>(data: NSData, completion:(ConcreteType)->()){
		
		let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		completion(ConcreteType(json: json!))
		
	}
}