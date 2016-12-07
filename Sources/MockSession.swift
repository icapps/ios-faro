import Foundation

open class MockURLSession: URLSession {

    open override func invalidateAndCancel() {
        // Do nothing
    }

    open override func finishTasksAndInvalidate() {
        // Do nothing
    }

}
open class MockSession: FaroQueueSessionable {

    public let session: URLSession
    public var data: Data?
    public var urlResponse: URLResponse?
    public var error: Error?

    var completionHandlers = [Int : ((Data?, URLResponse?, Error?) -> ())]()

    public init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
        self.session = MockURLSession()
    }

    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        let task = MockURLSessionTask()
        completionHandlers[task.taskIdentifier] = completionHandler
        return task
    }

    open func resume(_ task: URLSessionDataTask) {
        let completionHandler = completionHandlers[task.taskIdentifier]
        completionHandler?(data, urlResponse, error)
    }

}

open class MockAsyncSession: MockSession {

    private let delay: DispatchTimeInterval

    public init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil, delay: DispatchTimeInterval = .nanoseconds(1)) {
        self.delay = delay
        super.init(data: data, urlResponse: urlResponse, error: error)
    }

    open override func resume(_ task: URLSessionDataTask) {
        let delayTime = DispatchTime.now() + delay
        let completionHandler = completionHandlers[task.taskIdentifier]
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            (task as! MockURLSessionTask).mockedState = .completed
            completionHandler?(self.data, self.urlResponse, self.error)
        }
    }
    
}

open class MockURLSessionTask : URLSessionDataTask{

    private let uuid: UUID
    public override init() {
        uuid = UUID()
        super.init()
    }

    override open var taskIdentifier: Int {
        get {
            return uuid.hashValue
        }
    }

    var mockedState: URLSessionTask.State = .suspended

    override open var state: URLSessionTask.State {
        get {
            return mockedState
        }
    }

    override open func cancel() {
        mockedState = .canceling
    }


    override open func suspend() {
        mockedState = .suspended
    }

    override open func resume() {
        mockedState = .running
    }
    
}
