//
//  ServiceHandler.swift
//  Faro
//
//  Created by Stijn Willems on 02/11/2017.
//

import Foundation

public class ServiceHandler<M: Decodable>: Service {

    private let complete: (() throws -> (M)) -> Void
    private let completeArray: (() throws -> ([M])) -> Void
    /**
    Has the same parameters as super init plus complete handler.

     - Parameters:
     - call: points to the request you want to perform
     - autoStart: from the call a task is made. This task is returned by the perform function. The task is started automatically unless you set autoStart to no.
     - configuration: describes the base url to from a request with from the provided call.
     - faroSession: is a session that is derived from `URLSession`. By default this becomes an instance of `FaroSession`
     - complete: closure parameter that is stored on an instance. It is called everytime a session is called
     */
    public init(call: Call, autoStart: Bool = true,
                configuration: BackendConfiguration,
                faroSession: FaroSessionable = FaroSession(),
                complete: @escaping (() throws -> (M)) -> Void,
                completeArray: @escaping (() throws -> ([M])) -> Void) {
        self.complete = complete
        self.completeArray = completeArray
        super.init(call: call, autoStart: autoStart, configuration: configuration, faroSession: faroSession)
    }

    /**
     Will call the complete handler provided by the initializer.
    */
    @discardableResult
     public func perform() -> URLSessionDataTask? {
        return super.perform(M.self) {[weak self] (resultFunction) in
            self?.complete(resultFunction)
        }
    }

    @discardableResult
    public func performArray() -> URLSessionDataTask? {
        return super.perform([M].self) {[weak self] (resultFunction) in
            self?.completeArray(resultFunction)
        }
    }

}
