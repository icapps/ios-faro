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
open class Response {


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
	open func respond<Rivet: Rivetable>(_ data: Data?, urlResponse: URLResponse? = nil, error: Error? = nil,
	             succeed: @escaping (Rivet)->(), fail: ((ResponseError)->())?) {

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
	open func respond<Rivet: Rivetable>(_ data: Data?, urlResponse: URLResponse? = nil, error: Error? = nil, entity: Rivet? = nil,
	             succeed: @escaping ([Rivet])->(),  fail:((ResponseError)->())?){

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
	fileprivate func checkErrorAndReturnValidData(_ data: Data?, urlResponse: URLResponse? = nil, error: Error? = nil, mitigator: ResponseMitigatable, fail:((ResponseError)->())?) throws -> Data?{

		guard  error == nil else {
			respondWithfail(error!, fail: fail, mitigator: mitigator)
			return nil
		}
		guard let data = try ResponseUtils.checkStatusCodeAndData(data, urlResponse: urlResponse, error: error, mitigator: mitigator) else {
			return nil
		}
		return data
	}

	fileprivate func respondWithfail(_ error: Error ,fail:((ResponseError) ->())?) {
		if let responseError = error as? ResponseError {
			fail?(responseError)
		}else {
			print("💣 failed response with error: \(error)")
			fail?(ResponseError.general(statuscode: 0))
		}
	}
	fileprivate func respondWithfail(_ taskError: Error ,fail:((ResponseError) ->())?, mitigator: ResponseMitigatable) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try mitigator.responseError(taskError)
		}catch {
			fail?(ResponseError.responseError(error: taskError))
		}
	}
}

internal class ResponseUtils {
	class func checkStatusCodeAndData(_ data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil, mitigator: ResponseMitigatable) throws -> Data? {
        if let httpResponse = urlResponse as? HTTPURLResponse {
            
            let statusCode = httpResponse.statusCode

            guard statusCode != 404 else {
                try mitigator.invalidAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
				if let data = data{
					do {
						let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
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
