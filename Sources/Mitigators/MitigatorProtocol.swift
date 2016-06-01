//
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation


/**
A `Mitigator` recieves errors that happen. Mitigate means ‘make (something bad) less severe'.

So do that or rethrow what you cannot handle.
*/
public protocol Mitigator {
	/**
	See `MitigatorDefault` for an example implementation of this function. 
	
	- parameter thrower: A function used as a wrapper around throwing functions in `Air`, `Response` and `TransformJSON`.
	*/
	func mitigate(thrower: ()throws -> ()) throws
}

/**
Try to handle errors gracefully or rethrow them. The `MitigatorDefault` implements these methods.
*/
public protocol RequestMitigatable {
    func invalidBodyError() throws -> ()
    func generalError() throws -> ()
}

/**
Try to handle errors gracefully or rethrow them. The `MitigatorDefault` implements these methods.
*/
public protocol ResponseMitigatable {

	func invalidResponseData(data: NSData?) throws -> ()
	func invalidAuthenticationError() throws -> ()
	func responseError(error: NSError?) throws -> ()
	func generalError(statusCode: Int) throws -> ()
	func generalError(statusCode: Int , responseJSON: AnyObject) throws -> ()

	/**
	Your chance to intercept dictionary data that cannot is irregular. You can fix it and don't trow.
	- returns : a valid dictionary that can be transformed
	- throws: When you cannot interpret the dictionary throw an error
	*/
	func invalidDictionary(dictionary: AnyObject) throws -> AnyObject?

	func enityShouldBeUniqueForJSON(json: AnyObject, typeName: String) throws
}

