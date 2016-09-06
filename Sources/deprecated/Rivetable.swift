import Foundation
import CoreData

/**
   React and/or solve errors that could arrise while the entity that conforms to `Mitigatable` is handeled.

   You can inspect how error mitigation is expected to behave by looking at `MitigatorDefaultSpec` and `ResponseSpec` in the tests of the Example project.
 */

@available( *, deprecated = 1.0.0, message = "use the Bar class")

public protocol Mitigatable: class {

	/**
	   By returning an error controller you can handle parsing errors.
	   - returns: By default an implementation of `MitigatorDefault` is returned via a protocol extension
	 */
	static func responseMitigator() -> protocol<ResponseMitigatable, Mitigator>
	/**
	   If an error happens while constructing an entity this error controller could handle the error if needed.
	   - returns: By default an implementation of `MitigatorDefault` is returned via a protocol extension
	 */
	static func requestMitigator() -> protocol<RequestMitigatable, Mitigator>
}

@available( *, deprecated = 1.0.0, message = "use the Bar class")

public protocol CoreDataManagedObjectContextRequestable {
	/**
	   You can choose to return something when you use core data.
	   - returns: `NSManagedObjectContext` that is used by the `TranformController` to create `Parsable` instances
	 */
	static func managedObjectContext() -> NSManagedObjectContext?
}

@available( *, deprecated = 1.0.0, message = "use the Bar class")

public protocol CoreDataEntityDescription {
	static func entityName() -> String
	static func uniqueValueKey() -> String
}

@available( *, deprecated = 1.0.0, message = "use the Bar class")

public protocol CoreDataParsable {

	/**
	   Required initializer that throwns when the json or the managedObjectContext. You do not have to use a managedObjectContext. You can use this protocol without the need for a managed object context.

	   - parameter json: valid json that can be mapped to the object being initialized
	   - parameter managedObjectContext: (optional) you could use this for use with CoreData. But that is optional
	   - returns: a `Parsable` instance
	   - throws: errors when managedObjectContext of json are not usable to initialize a `Parsable` instance
	 */

	init(json: AnyObject, managedObjectContext: NSManagedObjectContext?) throws

	static func lookupExistingObjectFromJSON(json: AnyObject, managedObjectContext: NSManagedObjectContext?) throws -> Self?

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

}
/**
   Implement so we can set data on your variables in the `TransformJSON`.
 */
@available( *, deprecated = 1.0.0, message = "use the Bar class")

public protocol Parsable {

	/**
	   Required initializer that throwns when the json or the managedObjectContext. You do not have to use a managedObjectContext. You can use this protocol without the need for a managed object context.

	   - parameter json: valid json that can be mapped to the object being initialized
	   - parameter managedObjectContext: (optional) you could use this for use with CoreData. But that is optional
	   - returns: a `Parsable` instance
	   - throws: errors when managedObjectContext of json are not usable to initialize a `Parsable` instance
	 */

	init(json: AnyObject) throws

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

	static func lookupExistingObjectFromJSON(json: AnyObject) throws -> Self?
}

/**
   Handle the data that you receive. Data can be anything you want
   - returns: By default a `TransformJSON` is returned that does: 'data ~> JSON ~> entities of your type'.
 */

@available( *, deprecated = 1.0.0, message = "use Bar.")

public protocol Transformable {

	/**
	   For now we only support JSON
	 */

	static func transform() -> TransformJSON

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

@available( *, deprecated = 1.0.0, message = "use Bar.")

public protocol EnvironmentConfigurable {

	static func environment() -> protocol<Environment, Mockable>

	/**
	 * An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
	 */
	static func contextPath() -> String
}

/**
   Every `Rivetable` instance should have an unique identifier so we can fetch the object in a collection.
 */

@available( *, deprecated = 1.0.0, message = "use Bar.")

public protocol UniqueAble {
	var uniqueValue: String? {
		get set
	}
}

/**
   An `Air` should be able to build up a request when your model object complies to the protocols below.
 */
@available( *, deprecated = 1.0.0, message = "use Bar.")

public typealias Rivetable = protocol<UniqueAble, EnvironmentConfigurable, Parsable, Mitigatable, Transformable>

@available( *, deprecated = 1.0.0, message = "use Bar.")

public typealias RivetableCoreData = protocol<UniqueAble, EnvironmentConfigurable, Mitigatable, Transformable, CoreDataParsable, CoreDataEntityDescription, CoreDataManagedObjectContextRequestable>
