

import Foundation

/**
The host for your data. Used in `BaseModel` protocol.
*/
public protocol Environment {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}
