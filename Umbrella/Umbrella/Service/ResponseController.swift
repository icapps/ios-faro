import Foundation

/**
* It is te task of this class to handle the errors related to a response.
*/

public class ResponseController {
	
	private let transformController: TransfromController
	
	public init(transfromController: TransfromController = TransfromController()) {
		self.transformController = transfromController
	}
	
	func handleResponse<ResponseType: BaseModel>(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), completion: (ResponseType)->()) {
		if (response.error == nil) {
			// Success
			let statusCode = (response.urlResponse as! NSHTTPURLResponse).statusCode
			print("--------------URL Session Task Succeeded: HTTP \(statusCode)---------------")
			transformController.objectDataToConcreteObject(response.data!, completion: { (concreteObject) -> () in
				completion(concreteObject)
			})
			
		}else {
			// Failure
			print("URL Session Task Failed: %@", response.error!.localizedDescription);
		}
	}
	
	func handleResponse<ResponseType: BaseModel>(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), completion: ([ResponseType])->()) {
		if (response.error == nil) {
			// Success
			let statusCode = (response.urlResponse as! NSHTTPURLResponse).statusCode
			print("--------------URL Session Task Succeeded: HTTP \(statusCode)---------------")
			transformController.objectsDataToConcreteObjects(response.data!, completion: { (responseArray) -> () in
				completion(responseArray)
			})
			
		}else {
			// Failure
			print("URL Session Task Failed: %@", response.error!.localizedDescription);
		}
	}
}

enum UmbrellaErrors: ErrorType {
	case badBody
}