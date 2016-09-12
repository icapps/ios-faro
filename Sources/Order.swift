public enum Method: String {
    case GET, POST, PUT, DELETE, PATCH
}

public class Order {
    public typealias Rules = [(nodeKey: String, rule: EngagementRule)]
    public let path: String
    public let method: Method

    /// The rules for the nodes that should be fetched.
    public let rulesOfEngagement: Rules?

    public init(path: String, method: Method = .GET, rulesOfEngagement: Rules? = nil) {
        self.path = path
        self.method = method
        self.rulesOfEngagement = rulesOfEngagement
    }

    public func request(withConfiguration configuration: Configuration) -> NSURLRequest? {
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: "\(configuration.baseURL)/\(path)")!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        mutableRequest.HTTPMethod = method.rawValue

        return mutableRequest
    }

    public func collectionRequestForConfiguration(configuration: Configuration) -> NSURLRequest? {
        return nil
    }

    /// Parse sub nodes or not
    public func engagementRuleForNodeKey(nodeKey: String) -> EngagementRule {
        guard let rulesOfEngagement = rulesOfEngagement else {
            return .None
        }

        if let rule = (rulesOfEngagement.filter { $0.nodeKey == nodeKey }).first {
            return rule.rule
        } else {
            return .None
        }
    }

    // TODO: #60 Add ability to paginate
}