
public struct Parameters {
    public let type: ParameterType
    public let parameters: [String: Any]
    
    public init?(type: ParameterType, parameters: [String: Any]) {
        switch type {
        case .urlComponents:
            guard let _ = parameters as? [String: String] else {
                printFaroError(FaroError.malformed(info: "url components should be only Strings"))
                return nil
            }
        default:
            break
        }

        self.type = type
        self.parameters = parameters
    }
    
}

public enum ParameterType {
    case httpHeader
    case jsonBody
    case urlComponents
}
