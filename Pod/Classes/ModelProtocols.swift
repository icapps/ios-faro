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
	If needed an error controller that is type specific can be made.
	The goal of this controller is to handle parsing/network errors that can be solve by you.
	*/
	var errorController: ErrorController {get set}

	static func getErrorController() -> ErrorController
}


public protocol Parsable {
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

	static func environment() ->  Environment

	/**
	* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
	*/
	static func contextPath() -> String
}

public protocol UniqueAble {
	var objectId: String? {get set}
}