import Foundation

public protocol Adaptable: class {
    func serialize<M: Parseable>(fromDataResult dataResult: Result<M>, result: (Result <M>) -> ())
}
