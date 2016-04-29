//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation


/**
React and/or solve errors that could arrise while the entity that conforms to `Mitigatable` is handeled.

You can inspect how error mitigation is expected to behave by looking at `DefaultMitigatorSpec` and `ResponseControllerSpec` in the tests of the Example project.
*/
public protocol Mitigatable {

	init ()
	/**
	By returning an error controller you can handle parsing errors.
	- returns: By default an implementation of `DefaultMitigator` is returned via a protocol extension
	*/
	func responseMitigator() -> protocol<ResponseMitigatable, Mitigator>
	/**
	If an error happens while constructing an entity this error controller could handle the error if needed.
	 - returns: By default an implementation of `DefaultMitigator` is returned via a protocol extension
	*/
	static func requestMitigator()-> protocol<RequestMitigatable, Mitigator>
}

/**
Implement so we can set data on your variables in the `TransformController`.
*/
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
		"rootKey": {<dictToParse>}
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

/**
 Every `Rivetable` instance should have an unique identifier so we can retreive the object in a collection.
 */
public protocol UniqueAble {
	var objectId: String? {get set}
}

/**
An `Air` should be able to build up a request when your model object complies to the protocols below.
*/
public typealias Rivetable = protocol<UniqueAble, EnvironmentConfigurable, Parsable, Mitigatable>
