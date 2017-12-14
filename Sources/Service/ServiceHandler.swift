//
//  ServiceHandler.swift
//  Faro
//
//  Created by Stijn Willems on 02/11/2017.
//

import Foundation

open class ServiceHandler<M: Decodable>: Service {

    private let complete: ((() throws -> (M)) -> Void)?
    private let completeArray: ((() throws -> ([M])) -> Void)?

    /**
    Has the same parameters as super init plus complete handler.

     - Parameters:
     - call: points to the request you want to perform
     - autoStart: from the call a task is made. This task is returned by the perform function. The task is started automatically unless you set autoStart to no.
     - configuration: describes the base url to from a request with from the provided call.
     - session: should have backendConfiguration set
     - complete: Optional closure parameter to be used when you expect a single object to be returned by the service
     - completeArray: Optional closure parameter to be used when you expect an Array of objects returned by the service
     */
    public init(call: Call, autoStart: Bool = true,
                complete: ((() throws -> (M)) -> Void)? = nil,
                completeArray: ((() throws -> ([M])) -> Void)? = nil) {
        self.complete = complete
        self.completeArray = completeArray
        super.init(call: call, autoStart: autoStart)
    }

    /**
     Will call the complete handler provided by the initializer.
    */
    @discardableResult
     public func perform() -> URLSessionTask? {
        return super.perform(M.self) {[weak self] (done) in
            guard let complete = self?.complete else {
                print("📡⁉️ \(self) has no complete for \(#function)")
                return
            }
            self?.complete?(done)
        }
    }

    @discardableResult
    public func performArray() -> URLSessionTask? {
        return super.perform([M].self) {[weak self] (done) in
            guard let completeArray = self?.completeArray else {
                print("📡⁉️ \(self) has no complete for \(#function)")
                return
            }
            self?.completeArray?(done)
        }
    }

}
