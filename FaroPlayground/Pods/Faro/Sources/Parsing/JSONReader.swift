class JSONReader: NSObject {
    static func parseFile(named: String!, for bundle: Bundle) -> Any? {
        var named = named.replacingOccurrences(of: "/", with: "_")
        let start = named.startIndex
        let end = named.index(named.startIndex, offsetBy: 1)

        let range = start..<end
        named = named.replacingCharacters(in: range, with: "")

        print("🍞 fetching file named: \(named)")

        do {
            #if os(iOS)
                if #available(iOS 9.0, *) {
                    guard let data = NSDataAsset(name: named, bundle: bundle)?.data else {
                        return nil
                    }
                    return try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                } else {
                    print("🖕🏻 Faro json mocking only works on iOS 9 or greater")
                    return nil
                }
            #endif

            #if os(OSX)
                if #available(OSX 10.11, *) {
                    guard let data = NSDataAsset(name: named, bundle: bundle)?.data else {
                        return nil
                    }
                    return try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                } else {
                    print("🖕🏻 Faro json mocking only works on macOS 10.11 or greater")
                    return nil
                }
            #endif

            #if os(tvOS)
                if #available(tvOS 9.0, *) {
                    guard let data = NSDataAsset(name: named, bundle: bundle)?.data else {
                        return nil
                    }
                    return try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                } else {
                    print("🖕🏻 Faro json mocking only works on tvoOS 9 or greater")
                    return nil
                }
            #endif

            #if os(watchOS)
                print("🖕🏻 Faro json mocking only works on iOS, tvOS and macOS")
                return nil
            #endif

        } catch {
            printFaroError(FaroError.nonFaroError(error))
            return nil
        }
    }
}
