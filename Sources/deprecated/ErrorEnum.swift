//
//  ErrorEnmu.swift
//  Pods
//
//  Created by Stijn Willems on 20/05/16.
//
//

import Foundation

@available(*, deprecated=1.0.0, message="use Faro.")
public enum RequestError: ErrorType {
	case InvalidBody
	case InvalidUrl
	case General
}

@available(*, deprecated=1.0.0, message="use Faro.")
public enum ResponseError:ErrorType {
	case InvalidResponseData(data: NSData?)
	case InvalidDictionary(dictionary: AnyObject)
	case ResponseError(error: NSError?)
	case InvalidAuthentication
	case General(statuscode: Int)
	case GeneralWithResponseJSON(statuscode: Int, responseJSON: AnyObject)
}

public enum MapError: ErrorType {
	case EnityShouldBeUniqueForJSON(json: AnyObject, typeName: String)
	case JSONHasNoUniqueValue(json: AnyObject)
}

public enum CoreDataError: ErrorType {
	case ShouldNotInitializeWithoutManagedObjectContext
	case ProvideARootKey
}