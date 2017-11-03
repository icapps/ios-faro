//
//  String+Mock.swift
//  Horizon Go
//
//  Created by Jelle Vandebeeck on 19/06/2017.
//  Copyright © 2017 Jelle Vandebeeck. All rights reserved.
//

import Foundation

extension String {
    
    /// Add a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially. The string should be prefixed with `/` in order
    /// to work for the request.
    ///
    /// - Parameters:
    ///   - statusCode: The stubbed status code
    ///   - dictionary: The stubbed JSON body code
    public func stub(statusCode: Int, dictionary: [String: Any]? = nil) {
        RequestStub.shared.append(path: self, statusCode: statusCode, dictionary: dictionary)
    }

    /// Add a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially. The string should be prefixed with `/` in order
    /// to work for the request.
    ///
    /// - Parameters:
    ///   - statusCode: The stubbed status code
    ///   - data: The stubbed JSON body data
    public func stub(statusCode: Int, data: Data? = nil) {
        RequestStub.shared.append(path: self, statusCode: statusCode, data: data)
    }
    
}
