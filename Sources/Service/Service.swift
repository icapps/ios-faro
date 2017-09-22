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

    open let configuration: Configuration
    let faroSession: FaroSessionable

    public init(call: Call, autoStart: Bool = true, configuration: Configuration, faroSession: FaroSessionable = FaroSession()) {
        self.configuration = configuration
        self.faroSession = faroSession
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
    open func perform<M>(_ type: M.Type, complete: @escaping(@escaping () throws -> (M)) -> Void) -> URLSessionDataTask?  where M: Decodable {
        let call = self.call

        guard let request = call.request(with: configuration) else {
            let error = FaroError.invalidUrl("\(self.configuration.baseURL)/\(call.path)", call: call)
            self.handleError(error)
            complete { throw error }
            return nil
        }

        let task = faroSession.dataTask(with: request, completionHandler: {(data, response, error) in
            let error = raisesFaroError(data: data, urlResponse: response, error: error, for: request)

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
                    return try self.configuration.decoder.decode(M.self, from: data)
                }
                return
            }
            guard let returnData = data else {
                let error = FaroError.invalidResponseData(data, call: call)
                self.handleError(error)
                complete { throw error }
                return
            }

            complete {
                do {
                    return  try self.configuration.decoder.decode(M.self, from: returnData)
                } catch let error as DecodingError {
                    let error = FaroError.decodingError(error, inData: returnData, call: call)
                    self.handleError(error)
                    throw error
                }
            }
        })

        guard autoStart else {
            return task
        }

        faroSession.resume(task)
        return task
    }

    // MARK: - Update model instead of create

    open func performUpdate<M>(on model: M, complete: @escaping(@escaping () throws -> ()) -> Void) -> URLSessionDataTask?  where M: Decodable & Updatable {
        let task = perform(M.self) { (resultFunction) in
            complete {
                let serviceModel = try resultFunction()
                try  model.update(serviceModel)
                return
            }
        }
        return task
    }

    open func performUpdate<M>(on modelArray: [M], complete: @escaping(@escaping () throws -> ()) -> Void) -> URLSessionDataTask?  where M: Decodable & Updatable {
        let task = perform([M].self) { (resultFunction) in
            complete {
                var serviceModels = Set(try resultFunction())
                try modelArray.forEach { element in
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

func raisesFaroError(data: Data?, urlResponse: URLResponse?, error: Error?, for request: URLRequest) -> Error? {
    guard error == nil else {
        return error
    }

    guard let httpResponse = urlResponse as? HTTPURLResponse else {
        let returnError = FaroError.networkError(0, data: data, request: request)
        return returnError
    }

    let statusCode = httpResponse.statusCode
    guard statusCode < 400 else {
        let returnError = FaroError.networkError(statusCode, data: data, request: request)
        return returnError
    }

    guard 200...204 ~= statusCode else {
        let returnError = FaroError.networkError(statusCode, data: data, request: request)
        return returnError
    }

    return nil
}
