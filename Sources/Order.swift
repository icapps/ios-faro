public enum Method: String {
    case GET, POST, PUT, DELETE, PATCH
}

// TODO: Add tests for these rules

/// The `EngagementRule` enum defines how deep a JSON is to be parsed
/**
 ```
    { node:subnode:{node:subnode:...}
 ```
*/
public enum EngagementRule {
    case None
    case ObjectDetermined // The rules of the Type to be parsed should be used.
    case Inline // Only the data that you already have
    case Exhaustive // fetch all sub entities via new service requests
    case ExhaustiveRecursive // fetch all sub entities of sub entities (nuclear)
}

public class Order {
    public typealias Rules = [(key: String, rule: EngagementRule)]
    public let path: String
    public let method: Method

    /// The rules for the nodes that should be fetched.
    public let rulesOfEngagement: Rules?

    public init(path: String, method: Method = .GET, rulesOfEngagement: Rules? = nil) {
        self.path = path
        self.method = method
        self.rulesOfEngagement = rulesOfEngagement
    }

    public func objectRequestConfiguration(configuration: Configuration) -> NSURLRequest? {

        // TODO: add GET
        return NSURLRequest(URL: NSURL(string: "\(configuration.baseURL)/\(path)")!)
    }

    public func collectionRequestForConfiguration(configuration: Configuration) -> NSURLRequest? {
        return nil
    }

    /// parse sub nodes or not
    func shouldParseNodeWithKey(key: String) -> Bool {
        // TODO: test rules
        return true
    }

    // TODO: Add ability to paginate
}