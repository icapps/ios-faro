import Foundation

open class JSONAdaptor: Adaptable {

    public init() {

    }

    open func serialize<M: Deserializable>(from data: Data, result: (Result <M>) -> ()) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            result(.json(json))
        } catch {
            guard let faroError = error as? FaroError else {
                print("💣 Unknown error \(error)")
                result(.failure(FaroError.general))
                return
            }

            result(.failure(faroError))
        }
    }

	open func serialize(_ data: Data, intermediate: (Intermediate)throws -> Void) throws {
		let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

		if let node = json as? [String: Any] {
			try intermediate(.jsonNode(node))
		} else if let array = json as? [[String: Any]] {
			try intermediate(.jsonArray(array))
		}
	}

}
