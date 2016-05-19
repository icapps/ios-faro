//
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation
import CoreData

/**
React and/or solve errors that could arrise while the entity that conforms to `Mitigatable` is handeled.

You can inspect how error mitigation is expected to behave by looking at `DefaultMitigatorSpec` and `ResponseSpec` in the tests of the Example project.
*/
public protocol Mitigatable: class {

	/**
	By returning an error controller you can handle parsing errors.
	- returns: By default an implementation of `DefaultMitigator` is returned via a protocol extension
	*/
	static func responseMitigator() -> protocol<ResponseMitigatable, Mitigator>
	/**
	If an error happens while constructing an entity this error controller could handle the error if needed.
	 - returns: By default an implementation of `DefaultMitigator` is returned via a protocol extension
	*/
	static func requestMitigator()-> protocol<RequestMitigatable, Mitigator>
}

/**
Implement so we can set data on your variables in the `TransformJSON`.
*/
public protocol Parsable {


	/**
	Required initializer that throwns when the json or the managedObjectContext. You do not have to use a managedObjectContext. You can use this protocol without the need for a managed object context.
	
	- parameter json: valid json that can be mapped to the object being initialized
	- parameter managedObjectContext: (optional) you could use this for use with CoreData. But that is optional
	- returns: a `Parsable` instance
	- throws: errors when managedObjectContext of json are not usable to initialize a `Parsable` instance
	*/

	init(json: AnyObject, managedObjectContext: NSManagedObjectContext?) throws

	/**
	Set all properties from the data
	- throws : `ResponseError.InvalidDictionary(dictionary: AnyObject)`
	*/
	func map(json: AnyObject) throws

	/**
	From a dictionary containing properties of the object
	- throws: `RequestError.InvalidBody`
	*/
	func toDictionary() throws -> NSDictionary?

	/**
	Should provide key in JSON to node of dict that can be parsed.
	
	```
	{
		"rootKey": {<dictToParse>}
	}
	```
	*/
	static func rootKey() -> String?

	/**
	You can choose to return something when you use core data.
	- returns: `NSManagedObjectContext` that is used by the `TranformController` to create `Parsable` instances
	*/
	static func managedObjectContext() -> NSManagedObjectContext?
}

/**
Handle the data that you receive. Data can be anything you want
- returns: By default a `TransformJSON` is returned that does: 'data ~> JSON ~> entities of your type'.
*/
public protocol Transformable {

	/**
	For now we only support JSON
	*/
	
	static func transform() -> TransformJSON
}

public protocol EnvironmentConfigurable {

	static func environment() ->  protocol<Environment, Mockable>

	/**
	* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
	*/
	static func contextPath() -> String
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
public typealias Rivetable = protocol<UniqueAble, EnvironmentConfigurable, Parsable, Mitigatable, Transformable>
