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

This error controller is used with the `RequestController`. You can inspect how error handling is expected to behave by looking at `RequestControllerSpec` in the tests of the Example project.
*/
public protocol ErrorControlable {

	/**
	By returning an error controller you can handle parsing errors.
	- returns: By default an implementation of `ConcreteErrorController` is returned via a protocol extension
	*/
	func responseErrorController() -> Mitigator
	/**
	If an error happens while constructing an entity this error controller could handle the error if needed.
	 - returns: By default an implementation of `ConcreteErrorController` is returned via a protocol extension
	*/
	static func requestErrorController() -> Mitigator
}

public protocol Parsable {
	init ()
	
	/**
	Set all properties from the data
	*/
	func parseFromDict(dict: AnyObject) throws

	/**
	From a dictionary containing properties of the object
	*/
	func toDictionary()-> NSDictionary?

	/**
	Should provide key in JSON to node of dict that can be parsed.
	
	```
	{
		rootKey: {<dictToParse>}
	}
	```
	*/
	static func rootKey() -> String?
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

