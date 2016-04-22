

import Foundation

/**
The environmont where we should fetch the data from.

Example environments:
* Pruduction
* Development
* Filesystem
* ...

*/
public protocol Environment: Mockable {
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