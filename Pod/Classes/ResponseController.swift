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
	
	func respond<ResponseType: protocol<Parsable, Mitigatable, UniqueAble> >(environment: Transformable, response:  (data: NSData?, urlResponse: NSURLResponse?), body: ResponseType? = nil, completion: (ResponseType)->()) throws {

        guard let data = try ResponseControllerUtils.checkStatusCodeAndData(response, mitigator: mitigator(body)) else {
			return
		}

		try environment.transformController().transform(data, body: body, completion: completion)
	}

	func respond<ResponseType: protocol<Parsable, Mitigatable, UniqueAble> >(environment: Transformable, response:  (data: NSData?, urlResponse: NSURLResponse?), body: ResponseType? = nil, completion: ([ResponseType])->()) throws{

		guard let data = try ResponseControllerUtils.checkStatusCodeAndData(response, mitigator: mitigator(body)) else {
			return
		}

		try environment.transformController().transform(data, body: body, completion: completion)
    }

	func mitigator<T: Mitigatable>(body: T? = nil) -> ResponsMitigatable {
		var mitigator: ResponsMitigatable

		if let body = body {
			mitigator = body.responseMitigator()
		}else {
			mitigator = T().responseMitigator()
		}

		return mitigator
	}
}

internal class ResponseControllerUtils {
    class func checkStatusCodeAndData(response: (data: NSData?, urlResponse: NSURLResponse?), mitigator: ResponsMitigatable) throws -> NSData? {
        if let httpResponse = response.urlResponse as? NSHTTPURLResponse {
            
            let statusCode = httpResponse.statusCode
            
            guard statusCode != 404 else {
                try mitigator.requestAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
                try mitigator.requestGeneralError()
                return nil
            }
            
            guard let data = response.data else {
                try mitigator.responseDataEmptyError()
                return nil
            }
            
            return data
        }
        else {
            return response.data
        }
    }
}