//
//  StubbedURLProtocol.swift
//  Horizon Go
//
//  Created by Jelle Vandebeeck on 14/06/2017.
//  Copyright © 2017 Jelle Vandebeeck. All rights reserved.
//

import Foundation

/// This class is responsible for returning the correct `HTTPURLResponse` when mocking the requests.
public class StubbedURLProtocol: URLProtocol {
    
    override open class func canInit(with request: URLRequest) -> Bool {
        print("🌧 CHECK STUBBED PATH", request.url?.path as Any)
        // Check if stubbed requests are found for the given path.
        return RequestStub.shared[request.url?.path] != nil
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override open func startLoading() {
        // Fetch the stubbed requests for the given path.
        if
            let url = request.url,
            let stubbedResponse = RequestStub.shared.removeStub(for: url.path) {
            print("🌧 STUBBED", url.path)
            
            // Prepare the response.
            if let response = HTTPURLResponse(url: url, statusCode: stubbedResponse.statusCode, httpVersion: nil, headerFields: nil) {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            // Load the data when set.
            if let data = stubbedResponse.data {
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        
        // Trigger the finish loading on the client.
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override open func stopLoading() {
    }
    
}
