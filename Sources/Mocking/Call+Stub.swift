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
    public func stub(statusCode: Int, body: [String: Any] = [String: Any]()) {
        RequestStub.shared.append(path: self.path, statusCode: statusCode, body: body)
    }

    /// Add a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially. The string should be prefixed with `/` in order
    /// to work for the request.
    ///
    /// - Parameters:
    ///   - statusCode: The stubbed status code
    ///   - body: The stubbed JSON body data
    public func stub(statusCode: Int, body: Data) {
        RequestStub.shared.append(path: self.path, statusCode: statusCode, body: body)
    }
}
