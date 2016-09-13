import Foundation

public protocol Adaptable: class {
    func serialize<M: Mappable>(fromDataResult dataResult: Result<M>, result: (Result <M>) -> ())
}