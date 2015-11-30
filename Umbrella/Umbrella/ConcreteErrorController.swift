//
//  ConcreteErrorController.swift
//  Umbrella
//
//  Created by Stijn Willems on 30/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

public class ConcreteErrorController: ErrorController {
	required public init(){
		
	}
	public func requestBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
	
	public func requestAuthenticationError() throws {
		print("-----------Authentication error-----")
		throw RequestError.InvalidAuthentication
	}
	
	public func requestGeneralError() throws {
		print("-----------General error-----")
		throw RequestError.General
	}
	
	public func requestResponseDataEmpty() throws {
		print("-----------Invalid response data-----")
		throw RequestError.InvalidResponseData
	}
	
	public func requestResponseError(error: NSError) throws {
		print("-----------Request failed with error-----")
		throw RequestError.ResponseError
	}
}