//
//  ServiceQueue.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

open class ServiceQueue {

	private let deprecatedServiceQueue: DeprecatedServiceQueue

	public init (deprecatedServiceQueue: DeprecatedServiceQueue) {
		self.deprecatedServiceQueue = deprecatedServiceQueue
	}

	// MARK: Requests that expect a JSON response

	open func single<T>(call: Call, autoStart: Bool, complete: @escaping(@escaping () throws -> (T)) -> Void) where T: JSONDeserializable & Deserializable {
		deprecatedServiceQueue.performJsonResult(call, autoStart: autoStart) { [unowned self] (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeObject(let node):
					// Convert node to model of type T. When this is not possible an error is thrown.
					complete {try T(node)}
				default:
					complete { [unowned self] in
						let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
						self.handleError(error)
						throw error
					}
				}
			case .failure(let error):
				complete {
					self.handleError(error)
					throw error
				}
			default:
				complete {
					let error = FaroError.invalidDeprecatedResult(resultString: "\(result)", call: call)
					self.handleError(error)
					throw error
				}
			}
		}
	}

	/// Converts every node in the json to T. When one of the nodes has invalid json conversion is stopped and an error is trhown.
	open func collection<T>(call: Call, autoStart: Bool, complete: @escaping ( @escaping() throws -> [T]) -> Void) where T: JSONDeserializable & Deserializable {
		deprecatedServiceQueue.performJsonResult(call, autoStart: autoStart) { [unowned self] (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeArray(let nodeArray):
					guard let nodeArray = nodeArray as? [[String: Any]] else {
						complete { [unowned self] in
							let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
							throw error
						}
						return
					}

					// Convert every node to model of type T. When this is not possible an error is thrown.

					complete { try nodeArray.map {try T($0)} }
				default:
					complete {
						let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
						self.handleError(error)
						throw error
					}
				}
			case .failure(let error):
				complete {
					self.handleError(error)
					throw error
				}
			default:
				complete {
					let error = FaroError.invalidDeprecatedResult(resultString: "\(result)", call: call)
					self.handleError(error)
					throw error
				}
			}
		}
	}

	// MARK: Error

	/// Prints the error and throws it
	/// Possible to override this to have custom behaviour for your app.
	open func handleError(_ error: FaroError) {
		printFaroError(error)
	}

	// MARK: - Interact with tasks

	open var hasOustandingTasks: Bool {
		get {
			return deprecatedServiceQueue.hasOustandingTasks
		}
	}

	open func resume(_ task: URLSessionDataTask) {
		deprecatedServiceQueue.faroSession.resume(task)
	}

	open func resumeAll() {
		deprecatedServiceQueue.resumeAll()
	}

}
