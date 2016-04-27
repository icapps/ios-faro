

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
You should only implement this protocol in unit tests or in your application while the service is not yet available.
When a type conforms to Mockable the environment you provide by conforming to `EnvironmentConfigurable` will be ignored.
*/
public protocol Mockable {
	func shouldMock() -> Bool
}

/**
	Handle the data that you receive. Data can be anything you want
	- returns: By default a `TransformController` is returned that does: 'data ~> JSON ~> entities of your type'.
*/
public protocol Transformable {
	func transformController() -> TransformController
}

public extension Transformable {
	func transformController() -> TransformController {
		return TransformController()
	}
}