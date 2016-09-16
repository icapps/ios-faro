import Foundation

public protocol Adaptable: class {
    func serialize<M: Parseable>(from data: Data, result: (Result <M>) -> ())
}
