import Foundation

public protocol Adaptable: class {
    func serialize<M: Deserializable>(from data: Data, result: (DeprecatedResult <M>) -> ())
}
