//
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation

/**
The environment where we should fetch the data from.

Example environments:

* Production
* Development
* Filesystem
* ...

*/
public protocol Environment {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}

/**
If you implement `Mockable` your entity can provide a default response. This can be handy for tests.
When a type conforms to Mockable the environment you provide by conforming to `EnvironmentConfigurable` will be ignored and files are loaded from local disk by `Air`.
*/
public protocol Mockable {
	func shouldMock() -> Bool
}

/**
	Handle the data that you receive. Data can be anything you want
	- returns: By default a `Transform` is returned that does: 'data ~> JSON ~> entities of your type'.
*/
public protocol Transformable {

	func transformController() -> Transform
}

public extension Transformable {
	func transformController() -> Transform {
		return Transform()
	}
}