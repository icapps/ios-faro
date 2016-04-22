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
	
	private let transformController: TransformController

	/**
	- parameter transformController: a default implementation is given that transforms from JSON to your model object of `ResponseType`
	- returns: Properly instantiated ResponseController
	*/
	public init(transformController: TransformController = TransformController()) {
		self.transformController = transformController
	}
	
	func handleResponse<ResponseType: protocol<Parsable, ErrorControlable> >(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), body: ResponseType? = nil, completion: (ResponseType)->()) throws {
		let errorController = ResponseType.constructionErrorController()
        try errorController.requestResponseError(response.error)
        
		if let data = try ResponseControllerUtils.checkStatusCodeAndData(response, errorController: errorController){
			try transformController.objectDataToConcreteObject(data, inputModel: body, completion: { (concreteObject) -> () in
				completion(concreteObject)
			})
		}
	}

	func handleResponse<ResponseType: protocol<Parsable, ErrorControlable> >(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), completion: ([ResponseType])->()) throws{
		let errorController = ResponseType.constructionErrorController()
        try errorController.requestResponseError(response.error)
        
		if let data = try ResponseControllerUtils.checkStatusCodeAndData(response, errorController: errorController) {
			try transformController.objectsDataToConcreteObjects(data, completion: { (responseArray) -> () in
				completion(responseArray)
			})
		}
    }
}

internal class ResponseControllerUtils {
    class func checkStatusCodeAndData(response: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), errorController: ErrorController) throws -> NSData? {
        if let httpResponse = response.urlResponse as? NSHTTPURLResponse {
            
            let statusCode = httpResponse.statusCode
            
            guard statusCode != 404 else {
                try errorController.requestAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
                try errorController.requestGeneralError()
                return nil
            }
            
            guard let data = response.data else {
                try errorController.responseDataEmptyError()
                return nil
            }
            
            return data
        }
        else {
            try errorController.responseInvalidError()
            return nil
        }
    }
}