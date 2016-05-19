//
//  DefaultMitigator.swift
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
public class DefaultMitigator: Mitigator, ResponseMitigatable, RequestMitigatable {

	public init () {
		
	}

	// MARK: Mitigator
    
	public func mitigate(thrower: ()throws -> ()) throws  {
		do {
			try thrower()
		}catch RequestError.InvalidBody{
			try invalidBodyError()
		}catch RequestError.General{
			try generalError()
		}catch ResponseError.InvalidResponseData(let data){
			try invalidResponseData(data)
		}catch ResponseError.InvalidDictionary(dictionary: let dict) {
			try invalidDictionary(dict)
		} catch ResponseError.ResponseError(error: let error) {
			try responseError(error)
		}catch {
			throw error
		}
	}

    // MARK: RequestMitigatable
    
	public func invalidBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}

	public func generalError() throws {
		print("💣 General request error")
		throw RequestError.General
	}

    
    // MARK: ResponseMitigatable
    
	public func invalidAuthenticationError() throws {
		print("🙃 Authentication error")
		throw ResponseError.InvalidAuthentication
	}

	public func invalidResponseData(data: NSData?) throws {
        print("🤔 Invalid response data")
        throw ResponseError.InvalidResponseData(data: data)
    }
    

	public func invalidDictionary(dictionary: AnyObject) throws -> AnyObject? {
		print("🤔 Received invalid dictionary \(dictionary)")
		throw ResponseError.InvalidDictionary(dictionary: dictionary)
	}

	public func responseError(error: NSError?) throws {
		print("💣 Request failed with error \(error)")
		throw ResponseError.ResponseError(error: error)
	}


	public func generalError(statusCode: Int) throws -> (){
		print("💣 General response error with statusCode: \(statusCode)")
		throw RequestError.General
	}


	public func generalError(statusCode: Int , responseJSON: AnyObject) throws -> () {
		print("💣 General response error with statusCode: \(statusCode) and responseJSON: \(responseJSON)")
		throw RequestError.General

	}
    
}