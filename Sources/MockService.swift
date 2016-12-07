open class MockService: Service {

    /// If you provide this variable before calling `perform` we will use this instead of the file content.
    public var mockDictionary: Any?
    internal var bundle: Bundle!

    public init(mockDictionary: Any? = nil,
                for bundle: Bundle = Bundle.main,
                faroSession: FaroSessionable = MockSession()) {
        self.mockDictionary = mockDictionary
        self.bundle = bundle
        super.init(configuration: Configuration(baseURL: ""), faroSession: faroSession)
    }

    /// This method is overridden to return json or errors like as if we would do a network call.
    @discardableResult
    override open func performJsonResult<M : Deserializable>(_ call: Call, autoStart: Bool = true, jsonResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {
        if let mockDictionary = mockDictionary {
            jsonResult(.json(mockDictionary))
            return MockURLSessionTask()
        }

        let request = call.request(withConfiguration: configuration)

        guard let url = request?.url?.absoluteString else {
            let faroError = FaroError.malformed(info: "No valid url")
            printFaroError(faroError)
            jsonResult(.failure(faroError))
            return MockURLSessionTask()
        }

        guard let mockJSON = JSONReader.parseFile(named: url, for: bundle!) else {
            let faroError = FaroError.malformed(info: "Could not find dummy file at \(url)")
            printFaroError(faroError)
            jsonResult(.failure(faroError))
            return MockURLSessionTask()
        }

        jsonResult(.json(mockJSON))
        return MockURLSessionTask()
    }
    
}

