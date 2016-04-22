//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation


/**
A `RequestController` should be able to build up a request when your model object complies to the protocols  below.
*/

/**
React and/or solve error that could arrise while
*/
public protocol ErrorControlable {

	/**
	By returning an error controller you can handle parsing errors.
	- returns: By default an implementation of `ConcreteErrorController` is returned via a protocol extension
	*/
	func parsingErrorController() -> ErrorController
	/**
	If an error happens while constructing an entity this error controller could handle the error if needed.
	 - returns: By default an implementation of `ConcreteErrorController` is returned via a protocol extension
	*/
	static func constructionErrorController() -> ErrorController
}

/**
Default implementation for `ErrorControlalbe`
*/
public extension ErrorControlable {

	func parsingErrorController () -> ErrorController {
		return ConcreteErrorController()
	}

	static func constructionErrorController() -> ErrorController {
		return ConcreteErrorController()
	}
}

public protocol Parsable {
	init ()
	/**
	* Set all properties from the received JSON at initialization
	*/
	init(json: AnyObject)
	/**
	* Set all properties from the received JSON
	*/
	func importFromJSON(json: AnyObject)

	/**
	* Override if you want to POST this as JSON
	*/
	func body()-> NSDictionary?
}


public protocol EnvironmentConfigurable {

	init ()
	
	func environment() ->  protocol<Environment, Mockable, Transformable>

	/**
	* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
	*/
	func contextPath() -> String
}


public protocol UniqueAble {
	var objectId: String? {get set}
}

