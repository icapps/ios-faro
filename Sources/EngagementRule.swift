// TODO: Add tests for these rules

/// The `EngagementRule` enum defines how deep a JSON is to be parsed
/**
 ```
 { node:subnode:{node:subnode:...}
 ```
 */
/// This is a placeholder for a fearue that we should have in the future
///  case ObjectDetermined // The rules of the Type to be parsed should be used.
/// case Inline // Only the data that you already have
/// case Exhaustive // fetch all sub entities via new service requests
/// case ExhaustiveRecursive // fetch all sub entities of sub entities (nuclear)
public enum EngagementRule: Equatable {
    case None // Stop parsing 1 node deep
    case All // Parse all
}

public func == (lhs: EngagementRule, rhs: EngagementRule) -> Bool {
    switch lhs {
    case .None:
        switch rhs {
        case .None:
            return true
        default:
            return false
        }
    case .All:
        switch rhs {
        case .All:
            return true
        default:
            return false
        }
    }
}