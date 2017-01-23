import Foundation

public protocol Adaptable: class {
    func serialize<M: Deserializable>(from data: Data, result: (Result <M>) -> Void)
	func serialize(_ data: Data, intermediate: (Intermediate) throws -> Void) throws
}
