//
//  ConcreteErrorController.swift
//  Umbrella
//
//  Created by Stijn Willems on 30/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

public class ConcreteErrorController: ErrorController {
    
    //MARK: RequestErrorController
    
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
	
	public func requestResponseError(error: NSError?) throws {
		print("-----------Request failed with error-----")
        if let error = error {
            throw RequestError.ResponseError(error: error)
        }
	}
    
    //MARK: ResponseErrorController
    
    public func responseDataEmptyError() throws {
        print("-----------Invalid response data-----")
        throw ResponseError.InvalidResponseData
    }
    
    public func responseInvalidError() throws {
        print("-----------Invalid response type-----")
        throw ResponseError.InvalidResponse
    }
    
    //MARK: TransformErrorController

//    public func transformJSONError() throws {
//        //
//    }
//    
//    public func transformInvalidObjectERror() throws {
//        //
//    }
}