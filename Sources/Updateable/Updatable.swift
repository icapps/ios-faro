import Foundation

public protocol Updatable: class, Hashable {

	func update(_ model: AnyObject) throws
    func update(array: [AnyObject]) throws

}
