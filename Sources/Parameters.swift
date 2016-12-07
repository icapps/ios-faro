
public struct Parameters {
    public let type: ParameterType
    public let parameters: [String: Any]
    
    public init?(type: ParameterType, parameters: [String: Any]) {
        switch type {
        case .urlComponents:
            guard let params = parameters as? [String: String] else {
                printFaroError(FaroError.malformed(info: "url components should be only Strings"))
                return nil
            }
            if (params.isEmpty) {
                printFaroError(FaroError.malformed(info: "url components can not be empty"))
                return nil
            }
            for (key, value) in params {
                if (key.isEmpty) {
                    printFaroError(FaroError.malformed(info: "key for value \"" + value + "\" can not be empty"))
                    return nil
                }
                if (value.isEmpty) {
                    printFaroError(FaroError.malformed(info: "value for key \"" + key + "\" can not be empty"))
                    return nil
                }
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
