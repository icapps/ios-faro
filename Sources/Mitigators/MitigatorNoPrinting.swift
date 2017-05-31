//
//  MitigatorNoPrinting.swift
//  Pods
//
//  Created by Stijn Willems on 20/05/16.
//
//

import Foundation

/**
Use this for instance in tests to disable printing. This is a subclass from `MitigatorDefault`. 
It has the same throwing behaviour but does not print.
*/

open class MitigatorNoPrinting: MitigatorDefault {

	// MARK: RequestMitigatable

	open override func invalidBodyError() throws -> () {
		throw RequestError.invalidBody
	}

	open override func generalError() throws {
		throw RequestError.general
	}


	// MARK: ResponseMitigatable

	open override func invalidAuthenticationError() throws {
		throw ResponseError.invalidAuthentication
	}

	open override func invalidResponseData(_ data: Data?) throws {
		throw ResponseError.invalidResponseData(data: data)
	}


	open override func invalidDictionary(_ dictionary: Any) throws -> Any? {
		throw ResponseError.invalidDictionary(dictionary: dictionary)
	}

	open override func responseError(_ error: Error?) throws {
		throw ResponseError.responseError(error: error)
	}


	open override func generalError(_ statusCode: Int) throws -> (){
		throw ResponseError.general(statuscode: statusCode)
	}


	open override func generalError(_ statusCode: Int , responseJSON: Any) throws -> () {
		throw ResponseError.generalWithResponseJSON(statuscode: statusCode, responseJSON: responseJSON)
	}

	open override func enityShouldBeUniqueForJSON(_ json: Any, typeName: String) throws {
		throw MapError.enityShouldBeUniqueForJSON(json: json, typeName: typeName)
	}

	open override func jsonHasNoUniqueValue(_ json: Any) throws {
		throw MapError.jsonHasNoUniqueValue(json: json)
	}
}
