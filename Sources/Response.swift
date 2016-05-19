//
//  ResponseController.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation

/**
Deal with the errors of the response and interpret the response.

#Tasks

## Handle errors in response
Errors cause an throw
## Pass response to the `TransformJSON`
Responses are interpretted in the `TransFormController`
*/
public class Response {


	public init() {
	}
	/**
	On success it returns an updated instance of type `Rivet`.

	- parameter data: The data to transform to type `Rivetable`
	- paramater urlResponse: The response from the `Environment`
	- parameter error: Any error that occured before calling this method
	- parameter succeed: Closure called on success
	- parameter fail: Closure called on failure
	*/
	public func respond<Rivet: Rivetable>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil,
	             succeed: (Rivet)->(), fail:((ResponseError)->())?) {

		do {
			let mitigator = Rivet.responseMitigator()
			try mitigator.mitigate {
				if let _ = try self.checkErrorAndReturnValidData(data, urlResponse: urlResponse, error: error, mitigator: mitigator, fail: fail){
					let transformController = Rivet.transform()
					try transformController.transform(data!, succeed: succeed)
				}
			}
		}catch {
			respondWithfail(error, fail: fail)
		}
	}

	/**
	On success it returns an array of type `Rivet`.
	
	- parameter data: The data to transform to type `Rivetable`
	- paramater urlResponse: The response from the `Environment`
	- parameter error: Any error that occured before calling this method
	- parameter succeed: Closure called on success
	- parameter fail: Closure called on failure
	*/
	public func respond<Rivet: Rivetable>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, entity: Rivet? = nil,
	             succeed: ([Rivet])->(),  fail:((ResponseError)->())?){

		do {
			let mitigator = Rivet.responseMitigator()
			try mitigator.mitigate {
				if let _ = try self.checkErrorAndReturnValidData(data, urlResponse: urlResponse, error: error, mitigator: mitigator, fail: fail){
					let transformController = Rivet.transform()
					try transformController.transform(data!, succeed: succeed)
				}
			}
		}catch {
			respondWithfail(error, fail: fail)
		}
	}

	//MARK: Private
	private func checkErrorAndReturnValidData(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, mitigator: ResponseMitigatable, fail:((ResponseError)->())?) throws -> NSData?{

		guard  error == nil else {
			respondWithfail(error!, fail: fail, mitigator: mitigator)
			return nil
		}
		guard let data = try ResponseUtils.checkStatusCodeAndData(data, urlResponse: urlResponse, error: error, mitigator: mitigator) else {
			return nil
		}
		return data
	}

	private func respondWithfail(error: ErrorType ,fail:((ResponseError) ->())?) {
		if let responseError = error as? ResponseError {
			fail?(responseError)
		}else {
			print("💣 failed response with error: \(error)")
			fail?(ResponseError.General(statuscode: 0))
		}
	}
	private func respondWithfail(taskError: NSError ,fail:((ResponseError) ->())?, mitigator: ResponseMitigatable) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try mitigator.responseError(taskError)
		}catch {
			fail?(ResponseError.ResponseError(error: taskError))
		}
	}
}

internal class ResponseUtils {
	class func checkStatusCodeAndData(data: NSData? = nil, urlResponse: NSURLResponse? = nil, error: NSError? = nil, mitigator: ResponseMitigatable) throws -> NSData? {
        if let httpResponse = urlResponse as? NSHTTPURLResponse {
            
            let statusCode = httpResponse.statusCode

            guard statusCode != 404 else {
                try mitigator.invalidAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
				if let data = data{
					do {
						let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
						try mitigator.generalError(statusCode, responseJSON: json)
					}catch {
						print("🤔 Received some response data for error but it is no JSON.")
						try mitigator.generalError(statusCode)
					}

				}else {
					try mitigator.generalError(statusCode)
				}
                return nil
            }
            
            guard let data = data else {
				try mitigator.invalidResponseData(nil)
                return nil
            }
            
            return data
        }
        else {
            return data
        }
    }
}