
//
//  Service.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

public enum Result<T> {
	case success(T)
	case fail(ServiceError)
}

public  enum ServiceError: Error {
	case fail(FaroError)
}

let json = [String: Any]()

/// We will always try to instantiate models using `JSONDeserializable`. 
/// `Deserializable` is for legacy reasons and will be removed in version 3.0
open class Service<T> where T: JSONDeserializable {

	open var call: Call
	open var autoStart: Bool

    open let configuration: Configuration
    let faroSession: FaroSessionable

    @available(*, deprecated:3.0, message:"no longer needed")
    let deprecatedService: DeprecatedService?

    public init(call: Call, autoStart: Bool = true, configuration: Configuration, faroSession: FaroSessionable = FaroSession()) {
        self.configuration = configuration
        self.faroSession = faroSession
        deprecatedService = nil
        self.autoStart = autoStart
        self.call = call
    }

	public  init(call: Call, autoStart: Bool = true, deprecatedService: DeprecatedService = FaroSingleton.shared) {
		self.deprecatedService = deprecatedService
        faroSession = deprecatedService.faroSession
        configuration = deprecatedService.configuration
		self.call = call
		self.autoStart = autoStart
	}

	// MARK: Requests that expect a JSON response and CREATE instances

	open func single(complete: @escaping(@escaping () throws -> (T)) -> Void) {
		let call = self.call

		deprecatedService?.performJsonResult(call, autoStart: autoStart) {[weak self] (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeObject(let node):
					// Convert node to model of type T. When this is not possible an error is thrown.
					complete {[weak self] in
						do {
							return try T(node)
						} catch {
							let faroError = FaroError.couldNotCreateInstance(ofType: "\(T.self)", call: call, error: error)
							self?.handleError(faroError)
							throw faroError
						}
					}
				default:
					complete { [weak self] in
						let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
						self?.handleError(error)
						throw error
					}
				}
			case .failure(let error):
				complete { [weak self] in
					self?.handleError(error)
					throw error
				}
			default:
				complete { [weak self] in
					let error = FaroError.invalidDeprecatedResult(resultString: "\(result)", call: call)
					self?.handleError(error)
					throw error
				}
			}
		}
	}

	/// Converts every node in the json to T. When one of the nodes has invalid json conversion is stopped and an error is trhown.
	open func collection(complete: @escaping ( @escaping() throws -> [T]) -> Void) {
		let call = self.call
		deprecatedService?.performJsonResult(call, autoStart: autoStart) { [weak self] (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeArray(let nodeArray):
					guard let nodeArray = nodeArray as? [[String: Any]] else {
						complete { [weak self] in
							let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
							self?.handleError(error)
							throw error
						}
						return
					}

					// Convert every node to model of type T. When this is not possible an error is thrown.

					complete {
						do {
							return try nodeArray.map {try T($0)}
						} catch {
							let faroError = FaroError.couldNotCreateInstance(ofType: "\(T.self)", call: call, error: error)
							self?.handleError(faroError)
							throw faroError
						}
					}
				default:
					complete { [weak self] in
						let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
						self?.handleError(error)
						throw error
					}
				}
			case .failure(let error):
				complete { [weak self] in
					self?.handleError(error)
					throw error
				}
			default:
				complete { [weak self] in
					let error = FaroError.invalidDeprecatedResult(resultString: "\(result)", call: call)
					self?.handleError(error)
					throw error
				}
			}
		}
	}

	// MARK: Error

	/// Prints the error and throws it
	/// Possible to override this to have custom behaviour for your app.
	open func handleError(_ error: FaroError) {
		print(error)
	}

}

// MARK: - Codable

extension Service {

    /// Gets a model(s) from the service and decodes it using native `Decodable` protocol.
    /// Provide a type, that can be an array, to decode the data received from the service into type 'M'
    @discardableResult
    open func perform<M>(_ type: M.Type, complete: @escaping(@escaping () throws -> (M)) -> Void) -> URLSessionDataTask?  where M: Decodable {
        let call = self.call

        guard let request = call.request(with: configuration) else {
            complete { throw FaroError.invalidUrl("\(self.configuration.baseURL)/\(call.path)", call: call)}
            return nil
        }

        let task = faroSession.dataTask(with: request, completionHandler: {(data, response, error) in
            let error = raisesFaroError(data: data, urlResponse: response, error: error, for: request)

            guard error == nil else {
                complete {throw error!}
                return
            }

            guard let returnData = data else {
                complete {throw FaroError.invalidResponseData(data, call: call)}
                return
            }
            complete {
                do {
                    return  try self.configuration.decoder.decode(M.self, from: returnData)
                } catch {
                    throw FaroError.decodingError(error, inData: returnData, call: call)
                }
            }
        })

        guard autoStart else {
            return task
        }

        faroSession.resume(task)
        return task
    }

}

// MARK: - Global error functions

func raisesFaroError(data: Data?, urlResponse: URLResponse?, error: Error?, for request: URLRequest) -> FaroError? {
    guard error == nil else {
        let returnError = FaroError.nonFaroError(error!)
        return returnError
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
