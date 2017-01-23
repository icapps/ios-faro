enum MockServiceError: Error {
	case noValidMockDataFound
}

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

	// MARK: - Override not Throwable

	/// This method is overridden to return json or errors like as if we would do a network call.
	@discardableResult
	override open func performJsonResult<M : Deserializable>(_ call: Call, autoStart: Bool = true, jsonResult: @escaping (Result<M>) -> ()) -> URLSessionDataTask? {
		if let mockDictionary = mockDictionary {
			jsonResult(.json(mockDictionary))
			return MockURLSessionTask()
		}

		guard let url = url(from: call) else {
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

	// MARK: - Override Throwable

	@discardableResult
	open override func performJsonResult(_ call: Call, autoStart: Bool = true,
	                                     intermediate: @escaping (Intermediate) throws -> (),
	                                     fail: @escaping (()throws ->()) -> () = faroDefaultThrowHandler) throws -> URLSessionDataTask {
		if let mockDictionary = mockDictionary as? [String: Any] {
			try intermediate(.jsonNode(mockDictionary))
			return MockURLSessionTask()
		} else if let mockDictionary = mockDictionary as? [[String: Any]] {
			try intermediate(.jsonArray(mockDictionary))
			return MockURLSessionTask()
		}

		guard let url = url(from: call) else {
			throw FaroError.malformed(info: "No valid url")
		}

		guard let mockJSON = JSONReader.parseFile(named: url, for: bundle!) else {
			throw FaroError.malformed(info: "Could not find dummy file at \(url)")
		}

		if let mockDictionary = mockJSON as? [String: Any] {
			try intermediate(.jsonNode(mockDictionary))
			return MockURLSessionTask()
		} else if let mockDictionary = mockJSON as? [[String: Any]] {
			try intermediate(.jsonArray(mockDictionary))
			return MockURLSessionTask()
		} else {
			throw MockServiceError.noValidMockDataFound
		}
	}

	/// You can override this for custom behaviour
	/// by default returns the url from the call
	open func url(from call: Call) -> String? {
		let request = call.request(withConfiguration: configuration)
		return request?.url?.absoluteString
	}

}

