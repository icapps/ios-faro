//
//  ErrorEnmu.swift
//  Pods
//
//  Created by Stijn Willems on 20/05/16.
//
//

import Foundation


public enum RequestError: Error {
	case invalidBody
	case invalidUrl
	case general
}

public enum ResponseError:Error {
	case invalidResponseData(data: Data?)
	case invalidDictionary(dictionary: Any)
	case responseError(error: Error?)
	case invalidAuthentication
	case general(statuscode: Int)
	case generalWithResponseJSON(statuscode: Int, responseJSON: Any)
}

public enum MapError: Error {
	case enityShouldBeUniqueForJSON(json: Any, typeName: String)
	case jsonHasNoUniqueValue(json: Any)
}
