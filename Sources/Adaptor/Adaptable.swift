import Foundation

public protocol Adaptable: class {
    func serialize<M: JSONDeserializable>(from data: Data, result: (DeprecatedResult <M>) -> ())
}
