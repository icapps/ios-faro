import Foundation

open class JSONAdaptor: Adaptable {

    public init() {

    }

    open func serialize<M: JSONDeserializable>(from data: Data, call: Call, result: (DeprecatedResult <M>) -> ()) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            result(.json(json))
        } catch {
            let error = FaroError.decodingError(error, inData: data, call: call)
            result(.failure(error))
		}
    }

}
