//
//  Call+Stub.swift
//  Faro
//
//  Created by Stijn Willems on 03/11/2017.
//

import Foundation

public extension Call {

    /// Add a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially. The string should be prefixed with `/` in order
    /// to work for the request.
    ///
    /// - Parameters:
    ///   - statusCode: The stubbed status code
    ///   - body: The stubbed JSON body code
    ///   - waitingTime: The time to wait until the stub responds.
    public func stub(statusCode: Int, dictionary: [String: Any]?, waitingTime: TimeInterval = 0.1) {
        RequestStub.shared.append(path: self.path, statusCode: statusCode, dictionary: dictionary, waitingTime: waitingTime)
    }

    /// Add a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially. The string should be prefixed with `/` in order
    /// to work for the request.
    ///
    /// - Parameters:
    ///   - statusCode: The stubbed status code
    ///   - body: The stubbed JSON body data
    ///   - waitingTime: The time to wait until the stub responds.
    public func stub(statusCode: Int, data: Data?, waitingTime: TimeInterval = 0.1) {
        RequestStub.shared.append(path: self.path, statusCode: statusCode, data: data, waitingTime: waitingTime)
    }
}
