import Foundation

/**
Deal with the errors of the response and interpret the respons.

#Tasks

## Handle errors in response
Errors cause an throw
## Pass response to the TransformController 
Responses are interpretted in the TransFormController
*/
public class ResponseController {

	/**
	- parameter transformController: a default implementation is given that transforms from JSON to your model object of `ResponseType`
	- returns: Properly instantiated ResponseController
	*/
	public init() {
	}
	
	func handleResponse<ResponseType: protocol<Parsable, ErrorControlable, UniqueAble> >(environment: Transformable,response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), body: ResponseType? = nil, completion: (ResponseType)->()) throws {
		let errorController = ResponseType.constructionErrorController()

		try checkError(response, errorController: errorController)
		if let data = try checkStatusCodeAndData(response, errorController: errorController){
			try environment.transFormcontroller().objectDataToConcreteObject(data, inputModel: body, completion: { (concreteObject) -> () in
				completion(concreteObject)
			})
		}
	}

	func handleResponse<ResponseType: protocol<Parsable, ErrorControlable> >(environment: Transformable, response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), completion: ([ResponseType])->()) throws{
		let errorController = ResponseType.constructionErrorController()

		try checkError(response, errorController: errorController)

		if let data = try checkStatusCodeAndData(response, errorController: errorController) {
			try environment.transFormcontroller().objectsDataToConcreteObjects(data, completion: { (responseArray) -> () in
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

		guard statusCode == 200 || statusCode == 201 else {
			if statusCode == 404{
				try errorController.requestAuthenticationError()
			}else {
				try errorController.requestGeneralError()
			}
			return nil
		}

		guard let data = response.data else {
			try errorController.requestResponseDataEmpty()
			return nil
		}

		return data
	}
}

enum UmbrellaErrors: ErrorType {
	case badBody
}