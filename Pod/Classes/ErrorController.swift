//
//  BaseModelError.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

/**
 * This class is responsible to handle errors in general and in a type specific way.
 */

public protocol RequestErrorController {
    func requestBodyError() throws -> ()
    func requestAuthenticationError() throws -> ()
    func requestGeneralError() throws -> ()
    func requestResponseError(error: NSError?) throws -> ()
}

public protocol ResponseErrorController {
    func responseDataEmptyError() throws -> ()
    func responseInvalidError() throws -> ()
	/**
	Your chance to intercept dictionary data that cannot is irregular. You can fix it and don't trow.
	*/
	func responseInvalidDictionary(dictionary: AnyObject) throws -> ()
}

public protocol TransformErrorController {
//    func transformInvalidObjectERror() throws -> ()
//    func transformDictionayError(diction) throws -> ()
}

public protocol ErrorController:RequestErrorController, ResponseErrorController, TransformErrorController
{
    
}

public enum RequestError: ErrorType {
	case InvalidBody
	case InvalidUrl
	case General
}

public enum ResponseError:ErrorType {
    case InvalidResponse
	case InvalidResponseData
	case InvalidDictionary(dictionary: AnyObject)
	case ResponseError(error: NSError?)
	case InvalidAuthentication
	case General
}