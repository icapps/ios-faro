open class MockService: Service {

    /// If you provide this variable before calling `perform` we will use this instead of the file content.
    public var mockDictionary: Any?
    internal var bundle: Bundle!
    
    public init(mockDictionary: Any? = nil, for bundle: Bundle = Bundle.main) {
        self.mockDictionary = mockDictionary
        self.bundle = bundle
        super.init(configuration: Configuration(baseURL: "mockService"))
    }

    /// Uses the `path` in the `Call` object to fetch data from a file located in an asset in the application bundle
    /// If you use this in unit tests include the files in the test target.
    /// If you provide a `mockDictionary` we will use this instead of the file content.
    override open func perform<M: Deserializable>(_ call: Call, result: @escaping (Result<M>) -> ()) {
        if let mockDictionary = mockDictionary {
            result(handle(json: mockDictionary, call: call))
            return
        }

        guard let mockJSON = JSONReader.parseFile(named: call.path, for: bundle!) else {
            let faroError = FaroError.malformed(info: "Could not find dummy file at \(call.path)")
            printFaroError(faroError)
            result(.failure(faroError))
            return
        }
        
        result(handle(json: mockJSON, call: call))
    }
    
}
