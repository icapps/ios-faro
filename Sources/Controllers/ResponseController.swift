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
## Pass response to the `TransformController`
Responses are interpretted in the `TransFormController`
*/
public class ResponseController {


	public init() {
	}
	/**
	On success it returns an updated instance of type `Rivet`.

	- parameter data: The data to transform to type `Rivetable`
	- paramater urlResponse: The response from the `Environment`
	- parameter error: Any error that occured before calling this method
	- paramter entity: Optional entity you want variables to be set on by the data proveded. If no entity provided one of type `Rivet` will be created
	- parameter succeed: Closure called on success
	- parameter fail: Closure called on failure
	*/
	public func respond<Rivet: Rivetable>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, entity: Rivet? = nil,
	             succeed: (Rivet)->(), fail:((ResponseError)->())?) {

		let entity = useBodyOrCreateEntity(entity)
		if let transformController = prepareTransFormOnEntity(data, urlResponse: urlResponse, error: error, entity: entity, fail: fail) {
			do {
				try transformController.transform(data!, entity: entity, succeed: succeed)
			}catch {
				respondWithfail(error, fail: fail)
			}
		}
	}

	/**
	On success it returns an array of type `Rivet`.
	
	- parameter data: The data to transform to type `Rivetable`
	- paramater urlResponse: The response from the `Environment`
	- parameter error: Any error that occured before calling this method
	- paramter entity: Optional entity you want variables to be set on by the data proveded. If no entity provided one of type `Rivet` will be created
	- parameter succeed: Closure called on success
	- parameter fail: Closure called on failure
	*/
	public func respond<Rivet: Rivetable>(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, entity: Rivet? = nil,
	             succeed: ([Rivet])->(),  fail:((ResponseError)->())?){

		let entity = useBodyOrCreateEntity(entity)
		if let transformController = prepareTransFormOnEntity(data, urlResponse: urlResponse, error: error, entity: entity, fail: fail) {
			do {
				try transformController.transform(data!, entity: entity, succeed: succeed)
			}catch {
				respondWithfail(error, fail: fail)
			}
		}
	}

	private func prepareTransFormOnEntity<Rivet: Rivetable>(data: NSData?,urlResponse: NSURLResponse?, error: NSError?, entity: Rivet, fail:((ResponseError)->())?) -> TransformController? {
		do {
			let mitigator = Rivet.responseMitigator()
			var result: TransformController?
			try mitigator.mitigate {
				if let _ = try self.checkErrorAndReturnValidData(data, urlResponse: urlResponse, error: error, mitigator: mitigator, fail: fail){
					let transformController = entity.environment().transformController()
					result =  transformController
				}
			}
			return result
		}catch {
			respondWithfail(error, fail: fail)
			return nil
		}
	}

	//MARK: Private
	private func checkErrorAndReturnValidData(data: NSData?, urlResponse: NSURLResponse? = nil, error: NSError? = nil, mitigator: ResponseMitigatable, fail:((ResponseError)->())?) throws -> NSData?{

		guard  error == nil else {
			respondWithfail(error!, fail: fail, mitigator: mitigator)
			return nil
		}
		guard let data = try ResponseControllerUtils.checkStatusCodeAndData(data, urlResponse: urlResponse, error: error, mitigator: mitigator) else {
			return nil
		}
		return data
	}

	private func useBodyOrCreateEntity<Rivet: Rivetable>(body: Rivet?) -> Rivet {
		var entity = body
		if entity == nil {
			entity = Rivet()
		}
		return entity!
	}

	private func respondWithfail(error: ErrorType ,fail:((ResponseError) ->())?) {
		if let responseError = error as? ResponseError {
			fail?(responseError)
		}else {
			print("💣 failed response with error: \(error)")
			fail?(ResponseError.General)
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