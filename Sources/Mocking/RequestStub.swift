//
//  RequestStub.swift
//  Horizon Go
//
//  Created by Jelle Vandebeeck on 14/06/2017.
//  Copyright © 2017 Jelle Vandebeeck. All rights reserved.
//

import Foundation

/// This reponse contains the stubbed data and status code that is returned for a given path.
public struct StubbedResponse {
    // The response's data.
    var data: Data?
    
    // The response's status code
    var statusCode: Int
}

/// The `RequestStub` handles everything that has to do with stubbing the requests, from swizzling the 
/// `URLSessionConfiguration` to registering the different stubs.
public class RequestStub {

    // MARK: - Internals
    
    private var responses = [String: [StubbedResponse]]()
    
    // MARK: - Init
    
    /// You should always use this singleton method to register stubs. This is needed because we need to be able to
    /// fetch the `responses` from within the `StubbedURLProtocol` class.
    public static var shared = RequestStub()
    
    public init() {
    }
    
    // MARK: - Class
    
    public class func removeAllStubs() {
        shared.removeAllStubs()
    }
    
    // MARK: - Mutating
    
    /// Append a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially.
    ///
    /// - Parameters:
    ///   - path: The path of the request, should be prefixid with "/"
    ///   - statusCode: The stubbed status code
    ///   - body: The stubbed JSON body code
    internal func append(path: String, statusCode: Int, body: [String: Any]?) {
        var data: Data?
        if let body = body {
            data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        }
        
        let response = StubbedResponse(data: data, statusCode: statusCode)
        var stubbedReponses = responses[path] ?? [StubbedResponse]()
        stubbedReponses.append(response)
        responses[path] = stubbedReponses
    }

    /// Append a body with status code to a given path. When calling this method multiple times for the same path
    /// these stubbed requests will be triggered sequentially.
    ///
    /// - Parameters:
    ///   - path: The path of the request, should be prefixid with "/"
    ///   - statusCode: The stubbed status code
    ///   - body: The stubbed JSON body code
    internal func append(path: String, statusCode: Int, body: Data?) {
        let response = StubbedResponse(data: body, statusCode: statusCode)
        var stubbedReponses = responses[path] ?? [StubbedResponse]()
        stubbedReponses.append(response)
        responses[path] = stubbedReponses
    }
    
    /// Removes the stub for the given path and returns it. When there are multiple responses for the path we will
    /// remove and return the first response.
    ///
    /// - Parameters:
    ///   - path: The path of the request, should be prefixid with "/"
    /// - Returns: The stubbed reponse if found
    internal func removeStub(for path: String?) -> StubbedResponse? {
        guard let path = path else { return nil }
        
        if self.responses[path]?.count ?? 0 > 0 {
            return self.responses[path]?.removeFirst()
        } else {
            self.responses.removeValue(forKey: path)
            return nil
        }
    }
    
    /// Remove all stubbed responses.
    private func removeAllStubs() {
        responses.removeAll()
    }
    
    // MARK: - Fetching
    
    /// Fetch stubbed reponses linked to a given path.
    ///
    /// - Parameters:
    ///   - path: The path of the request, should be prefixid with "/"
    /// - Returns: The stubbed reponses if found
    internal subscript(path: String?) -> [StubbedResponse]? {
        guard let path = path else { return nil }
        return responses.fetch(for: path)
    }
    
}

private extension Dictionary where Key == String {
    
    func fetch(for path: String?) -> Value? {
        guard
            let path = path,
            let key = keys.filter({ path.hasSuffix($0) }).first else {
                return nil
        }
        
        return self[key]
    }
    
}
