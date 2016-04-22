

import Foundation

/**
The environmont where we should fetch the data from.

Example environments:
* Pruduction
* Development
* Filesystem
* ...

*/
public protocol Environment {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}
