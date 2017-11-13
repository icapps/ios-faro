//
//  Service.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation


/*:
 Create a service instance to perform all kinds of requests. You can chose to use Service or its subclasses:

    1. ServiceHandler -> can be used for a single type and single handler
    2. ServicQueue -> can be used when you want to fire requests in paralel but want to know when all are done.

 All subclasses use this class to perform the requests.
 */
open class Service {

	open var call: Call
	open var autoStart: Bool

    public let session: FaroURLSession = FaroURLSession.shared()

    /**
     Init a servcie instance to perform calls

     - Parameters:
        - call: points to the request you want to perform
        - autoStart: from the call a task is made. This task is returned by the perform function. The task is started automatically unless you set autoStart to no.
        - configuration: describes the base url to from a request with from the provided call.
    */
    public init(call: Call, autoStart: Bool = true) {
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

    /*: Gets a model(s) from the service and decodes it using native `Decodable` protocol. To do this it asks the URLSession to provide a task.
        This task can be:

         1. DownloadTask for httpMethod GET (will finish in the background)
         2. UploadTask for httpMethod PUT, POST, PATCH (will finish in the background)
         3. DataTask for all others (NO finish in the background)

        Provide a type, that can be an array, to decode the data received from the service into type 'M'
            - parameter type: Generic type to decode the returend data to. If service returns no response data use type `Service.NoResponseData`
     */
    @discardableResult
    open func perform<M>(_ type: M.Type, complete: @escaping(@escaping () throws -> (M)) -> Void) -> URLSessionTask  where M: Decodable {
        let call = self.call
        let config = self.session.backendConfiguration
        let request = call.request(with: config)



        var task: URLSessionTask!
        let urlSession = FaroURLSession.shared().urlSession

        if call.httpMethod == .GET  {
            task = urlSession.downloadTask(with: request)
        } else if let body = request.httpBody {
            task = urlSession.uploadTask(with: request, from: body)
        } else {
            task = urlSession.dataTask(with:request)
        }

        session.tasksDone[task] = { [weak self] (data, response, error) in
            guard let `self` = self else {return}

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
