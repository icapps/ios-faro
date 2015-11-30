

import Foundation

//Know where to fetch data for the model type.

public protocol ServiceParameters {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}
