//
//  MockService.swift
//  Pods
//
//  Created by Ben Algoet on 27/09/16.
//
//

open class MockService: Service {
    
    public init() {
        super.init(configuration: Configuration(baseURL: "mockService"))
    }
    
    override open func perform<M: Deserializable>(_ call: Call, result: @escaping (Result<M>) -> ()) {
        guard let mockJSON = JSONReader.parseFile(named: call.path) else {
            result(.failure(.malformed(info: "Could not find dummy file at \(call.path)")))
            return
        }
        
        result(handle(json: mockJSON, call: call))
    }
    
}
