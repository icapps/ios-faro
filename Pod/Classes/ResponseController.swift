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
	
	func respond<Rivet: ModelProtocol>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, body: Rivet? = nil,
	             succeed: (Rivet)->(), fail:((ResponseError)->())? = nil) {

		let entity  = Rivet()
		let mitigator = entity.responseMitigator()

		guard  error == nil else {
			respondWithfail(error!, fail: fail, mitigator: mitigator)
			return
		}

		do {
			guard let data = try ResponseControllerUtils.checkStatusCodeAndData(data, urlResponse: urlResponse, error: error, mitigator: mitigator) else {
				return
			}

			try entity.environment().transformController().transform(data, body: body, completion: succeed)
		}catch {
			splitErrorType(error, fail: fail, mitigator: mitigator)
		}
	}

	func respond<Rivet: ModelProtocol>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, body: Rivet? = nil,
	             succeed: ([Rivet])->(),  fail:((ResponseError)->())? = nil){

		let entity  = Rivet()
		let mitigator = entity.responseMitigator()

		guard error == nil else {
			respondWithfail(error!, fail: fail, mitigator: mitigator)
			return
		}

		do {
			guard let data = try ResponseControllerUtils.checkStatusCodeAndData(data, urlResponse: urlResponse, error: error, mitigator: mitigator) else {
				return
			}

			try entity.environment().transformController().transform(data, body: body, completion: succeed)
		}catch {
			splitErrorType(error, fail: fail, mitigator: mitigator)
		}
    }

	private func respondWithfail(taskError: NSError ,fail:((ResponseError) ->())?, mitigator: ResponsMitigatable) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try mitigator.requestResponseError(taskError)
		}catch {
			fail?(ResponseError.ResponseError(error: taskError))
		}
		fail?(ResponseError.ResponseError(error: taskError))
	}

	private func splitErrorType(error: ErrorType, fail: ((ResponseError) ->())?, mitigator: ResponsMitigatable) {

		switch error {
		case ResponseError.InvalidAuthentication:
			do {
				try mitigator.requestAuthenticationError()
			}catch {
				fail?(ResponseError.InvalidAuthentication)
			}
		case ResponseError.InvalidDictionary(dictionary: let dictionary):
			do {
				try mitigator.responseInvalidDictionary(dictionary)
			}catch {
				let responsError = error as! ResponseError
				fail?(responsError)
			}
		default:
			print("---Error we could not process the response----")
			do {
				try mitigator.requestGeneralError()
			}catch {
				fail?(ResponseError.General)
			}
		}
	}
}

internal class ResponseControllerUtils {
	class func checkStatusCodeAndData(data: NSData? = nil, urlResponse: NSURLResponse? = nil, error: NSError? = nil, mitigator: ResponsMitigatable) throws -> NSData? {
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            
            let statusCode = httpResponse.statusCode
            
            guard statusCode != 404 else {
                try mitigator.requestAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
                try mitigator.requestGeneralError()
                return nil
            }
            
            guard let data = data else {
                try mitigator.responseDataEmptyError()
                return nil
            }
            
            return data
        }
        else {
            return data
        }
    }
}