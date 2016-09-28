import UIKit

class JSONReader: NSObject {
    static func parseFile(named: String!) -> [String : Any]? {
        do {
            guard let data = NSDataAsset(name: named, bundle: Bundle.init(for: self))?.data else {
                return nil
            }
            
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            printError(FaroError.nonFaroError(error))
            return nil
        }
    }
}
