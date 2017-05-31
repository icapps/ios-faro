//
//  MitigatorDefault.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation

/**
A mitigator tries to make a problem less servere. This is a default implementation that implements all the required protocols:

- `Mitigator` -> capture any thrown errors and rethrow them if needed.
- `ResponseMitigatable` -> Try to handle response errors. By default errors are printed and rethrown.
- `RequestMitigatable` -> Try to handle request errors.  By default errors are printed and rethrown.
*/
open class MitigatorDefault: Mitigator, ResponseMitigatable, RequestMitigatable {

	public init () {
		
	}

	// MARK: Mitigator
    
	open func mitigate(_ thrower: ()throws -> ()) throws  {
		do {
			try thrower()
		}catch RequestError.invalidBody{
			try invalidBodyError()
		}catch RequestError.general{
			try generalError()
		}catch ResponseError.invalidResponseData(let data){
			try invalidResponseData(data)
		}catch ResponseError.invalidDictionary(dictionary: let dict) {
			try invalidDictionary(dict)
		} catch ResponseError.responseError(error: let error) {
			try responseError(error)
		}catch ResponseError.general(statuscode: let code) {
			try generalError(code)
		}catch ResponseError.generalWithResponseJSON(statuscode: let code, responseJSON: let json) {
			try generalError(code, responseJSON: json)
		}catch MapError.enityShouldBeUniqueForJSON(json: let json, typeName: let typeName) {
			try enityShouldBeUniqueForJSON(json, typeName: typeName)
		}catch MapError.jsonHasNoUniqueValue(json: let json) {
			try jsonHasNoUniqueValue(json)
		}catch {
			throw error
		}
	}

    // MARK: RequestMitigatable
    
	open func invalidBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.invalidBody
	}

	open func generalError() throws {
		print("💣 General request error")
		throw RequestError.general
	}

    
    // MARK: ResponseMitigatable
    
	open func invalidAuthenticationError() throws {
		print("🙃 Authentication error")
		throw ResponseError.invalidAuthentication
	}

	open func invalidResponseData(_ data: Data?) throws {
        print("🤔 Invalid response data")
        throw ResponseError.invalidResponseData(data: data)
    }
    

	open func invalidDictionary(_ dictionary: Any) throws -> Any? {
		print("🤔 Received invalid dictionary \(dictionary)")
		throw ResponseError.invalidDictionary(dictionary: dictionary)
	}

	open func responseError(_ error: Error?) throws {
		print("💣 Request failed with error \(error)")
		throw ResponseError.responseError(error: error)
	}


	open func generalError(_ statusCode: Int) throws -> (){
		print("💣 General response error with statusCode: \(statusCode)")
		throw ResponseError.general(statuscode: statusCode)
	}


	open func generalError(_ statusCode: Int , responseJSON: Any) throws -> () {
		print("💣 General response error with statusCode: \(statusCode) and responseJSON: \(responseJSON)")
		throw ResponseError.generalWithResponseJSON(statuscode: statusCode, responseJSON: responseJSON)
	}

	open func enityShouldBeUniqueForJSON(_ json: Any, typeName: String) throws {
		print("🤔 We should have a unique entity in database for type: \(typeName) and responseJSON: \(json)")
		throw MapError.enityShouldBeUniqueForJSON(json: json, typeName: typeName)
	}

	open func jsonHasNoUniqueValue(_ json: Any) throws {
		print("🤔 json should contain a unique value. Received json: \(json)")
		throw MapError.jsonHasNoUniqueValue(json: json)
	}
}
