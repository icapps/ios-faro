//
//  MockSession.swift
//  Pods
//
//  Created by Stijn Willems on 14/11/2016.
//
//

import Foundation

open class MockSession: FaroQueueSessionable {

    public let session: URLSession
    public var data: Data?
    public var urlResponse: URLResponse?
    public var error: Error?

    var completionHandler: ((Data?, URLResponse?, Error?) -> ())?

    public init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
        self.session = URLSession()
    }

    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        self.completionHandler = completionHandler
        return MockURLSessionTask()
    }

    open func resume(_ task: URLSessionDataTask) {
        completionHandler?(data, urlResponse, error)
    }
    
}

open class MockAsyncSession: MockSession {

    private let delay: DispatchTimeInterval

    public init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil, delay: DispatchTimeInterval = .nanoseconds(1)) {
        self.delay = delay
        super.init(data: data, urlResponse: urlResponse, error: error)
    }
    open override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        self.completionHandler = completionHandler

        return MockURLSessionTask()
    }

    open override func resume(_ task: URLSessionDataTask) {
        let delayTime = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            print("Called completion \(delayTime)")
            self.completionHandler?(self.data, self.urlResponse, self.error)
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

    override open func cancel() {

    }


    override open func suspend() {

    }

    override open func resume() {
        
    }
    
}
