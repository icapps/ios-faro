import Foundation

/**
* It is te task of this class to handle the errors related to a response.
*/

public class ResponseController {
	
	private let transformController: TransfromController
	
	public init(transfromController: TransfromController = TransfromController()) {
		self.transformController = transfromController
	}
	
	func handleResponse<ResponseType: BaseModel>(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), body: ResponseType? = nil, completion: (ResponseType)->()) throws {
		let errorController = ResponseType.getErrorController()

		try checkError(response, errorController: errorController)
		if let data = try checkStatusCodeAndData(response, errorController: errorController){
			try transformController.objectDataToConcreteObject(data, body: body, completion: { (concreteObject) -> () in
				completion(concreteObject)
			})
		}
	}
	//TODO: #5 transformation of array results to existing objects.
	func handleResponse<ResponseType: BaseModel>(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), completion: ([ResponseType])->()) throws{
		let errorController = ResponseType.getErrorController()
		
		try checkError(response, errorController: errorController)
		
		if let data = try checkStatusCodeAndData(response, errorController: errorController) {
			try transformController.objectsDataToConcreteObjects(data, completion: { (responseArray) -> () in
				completion(responseArray)
			})
		}
	}
	
	private func checkError(response: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), errorController: ErrorController) throws{
		if let error = response.error {
			print("URL Session Task Failed: %@", response.error!.localizedDescription);
			try errorController.requestResponseError(error)
		}
	}
	private func checkStatusCodeAndData(response: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), errorController: ErrorController) throws -> NSData? {
		let statusCode = (response.urlResponse as! NSHTTPURLResponse).statusCode
		print("--------------URL Response: statusCode \(statusCode)---------------")
		if statusCode == 200 || statusCode == 201 {
			
		}else  if statusCode == 404{
			try errorController.requestAuthenticationError()
		}else {
			try errorController.requestGeneralError()
		}
		if let data = response.data {
			return data
		}else {
			try errorController.requestResponseDataEmpty()
		}
		return nil
	}
}

enum UmbrellaErrors: ErrorType {
	case badBody
}