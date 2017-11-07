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

    var finishLoading: (() -> Void)?

    override open class func canInit(with request: URLRequest) -> Bool {
        var path = request.url?.path
        path?.removeFirst()
        print("🌧 CHECK STUBBED PATH", path ?? "!! NO PATH!!")
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

            // Set the finish loading closure. We use a closure to allow cancel
            finishLoading = { [weak self] in
                guard let `self` = self else {return}
                self.client?.urlProtocolDidFinishLoading(self)
            }

            // Wait to call finish loading
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + stubbedResponse.waitingTime) {
                // Trigger the finish loading on the client.
                self.finishLoading?()
            }
        } else {
            print("⁉️ No STUB for \(request.url) in \(RequestStub.shared)")
            self.client?.urlProtocolDidFinishLoading(self)
        }


    }
    
    override open func stopLoading() {
        print("Stub is requested to stop loading")
        finishLoading = nil
    }
    
}
