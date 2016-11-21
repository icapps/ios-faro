//
//  MockSession.swift
//  Pods
//
//  Created by Stijn Willems on 14/11/2016.
//
//

import Foundation

open class MockSession: FaroSession {

    public var data: Data?
    public var urlResponse: URLResponse?
    public var error: Error?

    private var completionHandler: ((Data?, URLResponse?, Error?) -> ())?

    public init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }

    open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        self.completionHandler = completionHandler
        return URLSessionDataTask() // just to me able to mock
    }

    open func resume(_ task: URLSessionDataTask) {
        completionHandler?(data, urlResponse, error)
    }
    
}
