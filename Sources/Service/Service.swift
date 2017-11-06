//
//  Service.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

open class Service {

	open var call: Call
	open var autoStart: Bool

    public let session: FaroURLSession

    /**
     Init a servcie instance to perform calls

     - Parameters:
        - call: points to the request you want to perform
        - autoStart: from the call a task is made. This task is returned by the perform function. The task is started automatically unless you set autoStart to no.
        - configuration: describes the base url to from a request with from the provided call.
        - faroSession: is a session that is derived from `URLSession`. By default this becomes an instance of `FaroSession`
    */
    public init(call: Call, autoStart: Bool = true, session: FaroURLSession) {
        self.session = session
        self.autoStart = autoStart
        self.call = call
    }

	// MARK: Error

	/// Prints the error and throws it
	/// Possible to override this to have custom behaviour for your app.
	open func handleError(_ error: Error) {
		print(error)
	}

}

// MARK: - Perform Call and decode

extension Service {

    /// Gets a model(s) from the service and decodes it using native `Decodable` protocol.
    /// Provide a type, that can be an array, to decode the data received from the service into type 'M'
    /// - parameter type: Generic type to decode the returend data to. If service returns no response data use type `Service.NoResponseData`
    @discardableResult
    open func perform<M>(_ type: M.Type, complete: @escaping(@escaping () throws -> (M)) -> Void) -> URLSessionTask?  where M: Decodable {
        let call = self.call
        let config = self.session.backendConfiguration

        guard let request = call.request(with: config) else {
            let error = CallError.invalidUrl("\(config.baseURL)/\(call.path)", call: call)
            self.handleError(error)
            complete { throw error }
            return nil
        }


        // TODO: Handle upload
        var task = call.httpMethod == .GET  ?  session.session.downloadTask(with: request): session.session.dataTask(with: request) // Will call on delegate of session
        session.tasksDone[task] = { [weak self] (data, response, error) in
            guard let `self` = self else {return}
            print("\(data), \(response), \(error)")
            let error = raisesServiceError(data: data, urlResponse: response, error: error, for: request)

            guard error == nil else {
                self.handleError(error!)
                complete { throw error! }
                return
            }

            guard type.self != Service.NoResponseData.self else {
                complete {
                    // Constructing a no data data with an empty response
                    let data = """
                    {}
                    """.data(using: .utf8)!
                    return try config.decoder.decode(M.self, from: data)
                }
                return
            }
            guard let returnData = data else {
                let error = ServiceError.invalidResponseData(data, call: call)
                self.handleError(error)
                complete { throw error }
                return
            }

            complete {
                do {
                    return  try config.decoder.decode(M.self, from: returnData)
                } catch let error as DecodingError {
                    let error = ServiceError.decodingError(error, inData: returnData, call: call)
                    self.handleError(error)
                    throw error
                }
            }
        }
        guard autoStart else {
            return task
        }

        task.resume()
        return task
    }

    // MARK: - Update model instead of create

    open func performUpdate<M>(model: M, complete: @escaping(@escaping () throws -> ()) -> Void) -> URLSessionTask?  where M: Decodable & Updatable {
        let task = perform(M.self) { (resultFunction) in
            complete {
                let serviceModel = try resultFunction()
                try  model.update(serviceModel)
                return
            }
        }
        return task
    }

    open func performUpdate<M>(array: [M], complete: @escaping(@escaping () throws -> ()) -> Void) -> URLSessionTask?  where M: Decodable & Updatable {
        let task = perform([M].self) { (resultFunction) in
            complete {
                var serviceModels = Set(try resultFunction())
                try array.forEach { element in
                    try element.update(array: Array(serviceModels))
                    serviceModels.remove(element)
                }
                return
            }
        }
        return task
    }
    // MARK - No response data Type

    /// Use this type for `perform` when service returns no data
    public struct NoResponseData: Decodable {

    }

}

// MARK: - Global error functions

func raisesServiceError(data: Data?, urlResponse: URLResponse?, error: Error?, for request: URLRequest) -> Error? {
    guard error == nil else {
        return error
    }

    guard let httpResponse = urlResponse as? HTTPURLResponse else {
        let returnError = ServiceError.networkError(0, data: data, request: request)
        return returnError
    }

    let statusCode = httpResponse.statusCode
    guard statusCode < 400 else {
        let returnError = ServiceError.networkError(statusCode, data: data, request: request)
        return returnError
    }

    guard 200...204 ~= statusCode else {
        let returnError = ServiceError.networkError(statusCode, data: data, request: request)
        return returnError
    }

    return nil
}
