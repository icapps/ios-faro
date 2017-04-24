public enum Parameter {
    case httpHeader([String: String])
    case jsonArray([[String: Any]])
    case jsonNode([String: Any])
    case urlComponents([String: String])
    case multipart(MultipartFile)
}
