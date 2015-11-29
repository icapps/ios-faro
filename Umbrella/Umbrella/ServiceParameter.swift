

import Foundation

public protocol ServiceParameter {
	var serverUrl: String { get }
	var request: NSMutableURLRequest { get}
}
