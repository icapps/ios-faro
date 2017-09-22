import Foundation

public protocol Updatable: class, Hashable {
    associatedtype M: Decodable

	func update<M>(_ model: M) throws
    func update<M>(array: M) throws

}
