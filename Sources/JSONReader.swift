import UIKit

class JSONReader: NSObject {
    static func parseFile(named: String!, for bundle: Bundle) -> Any? {
        var named = named.replacingOccurrences(of: "/", with: "_")
        let start = named.startIndex
        let end = named.index(named.startIndex, offsetBy: 1)

        let range = start..<end
        named = named.replacingCharacters(in: range , with: "")

        print("🍞 fetching file named: \(named)")

        do {
            if #available(iOS 9.0, *) {
                guard let data = NSDataAsset(name: named, bundle: bundle)?.data else {
                    return nil
                }
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments)

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
