import UIKit

class JSONReader: NSObject {
    static func parseFile(named: String!, for bundle: Bundle) -> [String : Any]? {
        let named = named.replacingOccurrences(of: "/", with: "_")

        do {
            if #available(iOS 9.0, *) {
                guard let data = NSDataAsset(name: named, bundle: bundle)?.data else {
                    return nil
                }
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

            } else {
                print("🖕🏻 Faro json mocking only works on iOS 9")
               return nil
            }

        } catch {
                printFaroError(FaroError.nonFaroError(error))
                return nil
        }
    }
}
