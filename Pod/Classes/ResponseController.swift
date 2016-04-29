import Foundation

/**
Deal with the errors of the response and interpret the response.

#Tasks

## Handle errors in response
Errors cause an throw
## Pass response to the `TransformController`
Responses are interpretted in the `TransFormController`
*/
public class ResponseController {

	/**
	- parameter transformController: a default implementation is given that transforms from JSON to your model object of `ResponseType`
	- returns: Properly instantiated `ResponseController`
	*/
	public init() {
	}
	
	func respond<Rivet: Rivetable>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, body: Rivet? = nil,
	             succeed: (Rivet)->(), fail:((ResponseError)->())?) {

		let entity = useBodyOrCreateEntity(body)
		let mitigator = entity.responseMitigator()
		guard let data = checkErrorAndReturnValidData(data, urlResponse: urlResponse, error: error, mitigator: mitigator, fail: fail) else {
			return
		}

		do {
			try entity.environment().transformController().transform(data, entity: entity, succeed: succeed)
		}catch {
			splitErrorType(error, fail: fail, mitigator: mitigator)
		}

	}

	func respond<Rivet: Rivetable>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, body: Rivet? = nil,
	             succeed: ([Rivet])->(),  fail:((ResponseError)->())?){

		let entity = useBodyOrCreateEntity(body)
		let mitigator = entity.responseMitigator()
		guard let data = checkErrorAndReturnValidData(data, urlResponse: urlResponse, error: error, mitigator: mitigator, fail: fail) else {
			return
		}

		do {
			try entity.environment().transformController().transform(data, entity: entity, succeed: succeed)
		}catch {
			splitErrorType(error, fail: fail, mitigator: mitigator)
		}
    }


	private func checkErrorAndReturnValidData(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, mitigator: ResponseMitigatable, fail:((ResponseError)->())?) -> NSData?{

		guard  error == nil else {
			respondWithfail(error!, fail: fail, mitigator: mitigator)
			return nil
		}

		do {
			guard let data = try ResponseControllerUtils.checkStatusCodeAndData(data, urlResponse: urlResponse, error: error, mitigator: mitigator) else {
				return nil
			}
			return data
		}catch {
			splitErrorType(error, fail: fail, mitigator: mitigator)
			return nil
		}
	}

	private func useBodyOrCreateEntity<Rivet: Rivetable>(body: Rivet?) -> Rivet {
		var entity = body
		if entity == nil {
			entity = Rivet()
		}
		return entity!
	}

	private func respondWithfail(taskError: NSError ,fail:((ResponseError) ->())?, mitigator: ResponseMitigatable) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try mitigator.responseError(taskError)
		}catch {
			fail?(ResponseError.ResponseError(error: taskError))
		}
		fail?(ResponseError.ResponseError(error: taskError))
	}

	private func splitErrorType(error: ErrorType, fail: ((ResponseError) ->())?, mitigator: ResponseMitigatable) {

		switch error {
		case ResponseError.InvalidAuthentication:
			do {
				try mitigator.invalidAuthenticationError()
			}catch {
				fail?(ResponseError.InvalidAuthentication)
			}
		case ResponseError.InvalidDictionary(dictionary: let dictionary):
			do {
				try mitigator.responseInvalidDictionary(dictionary)
				//TODO: retry transforming once
			}catch {
				let responsError = error as! ResponseError
				fail?(responsError)
			}
		default:
			print("---Error we could not process the response----")
			do {
				try mitigator.generalError()
			}catch {
				fail?(ResponseError.General)
			}
		}
	}
}

internal class ResponseControllerUtils {
	class func checkStatusCodeAndData(data: NSData? = nil, urlResponse: NSURLResponse? = nil, error: NSError? = nil, mitigator: ResponseMitigatable) throws -> NSData? {
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            
            let statusCode = httpResponse.statusCode
            
            guard statusCode != 404 else {
                try mitigator.invalidAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
                try mitigator.generalError()
                return nil
            }
            
            guard let data = data else {
                try mitigator.invalidResponseEmptyDataError()
                return nil
            }
            
            return data
        }
        else {
            return data
        }
    }
}