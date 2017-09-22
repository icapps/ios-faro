import Foundation

open class JSONAdaptor: Adaptable {

    public init() {

    }

    open func serialize<M: JSONDeserializable>(from data: Data, result: (DeprecatedResult <M>) -> ()) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            result(.json(json))
        } catch {
           result(.failure(FaroError.jsonAdaptor(error: error, inDataString: String(data: data, encoding: .utf8) ?? "Data not in utf8 format.")))
		}
    }

}
