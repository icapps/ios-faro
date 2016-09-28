import UIKit

class JSONReader: NSObject {
    static func parseFile(named: String!, for bundle: Bundle) -> [String : Any]? {
        do {
            guard let data = NSDataAsset(name: named, bundle: bundle)?.data else {
                return nil
            }
            
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            PrintFaroError(FaroError.nonFaroError(error))
            return nil
        }
    }
}
