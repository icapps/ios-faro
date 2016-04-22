

import Foundation

/**
The host for your data. Used in `BaseModel` protocol.
*/
public protocol Host {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}
