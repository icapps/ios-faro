import Foundation

public protocol Adaptable: class {
    func serialize<M: Mappable>(fromDataResult dataResult: Result<M>, jsonResult: (Result <M>) -> ())
}