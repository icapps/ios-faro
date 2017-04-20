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
		deprecatedServiceQueue.performJsonResult(call, autoStart: autoStart) { (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeObject(let node):
					// Convert node to model of type T. When this is not possible an error is thrown.
					complete {try T(node)}
				default:
					complete { [unowned self] in
						throw FaroError.noModelFor(call: call, inJson: rootNode)
					}
				}
			case .failure(let error):
				complete {throw error}
			default:
				complete {throw FaroError.general}
			}
		}
	}

	/// Converts every node in the json to T. When one of the nodes has invalid json conversion is stopped and an error is trhown.
	open func collection<T>(call: Call, autoStart: Bool, complete: @escaping ( @escaping() throws -> [T]) -> Void) where T: JSONDeserializable & Deserializable {
		deprecatedServiceQueue.performJsonResult(call, autoStart: autoStart) { (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeArray(let nodeArray):
					guard let nodeArray = nodeArray as? [[String: Any]] else {
						complete { [unowned self] in
							throw FaroError.noModelFor(call: call, inJson: rootNode)
						}
						return
					}

					// Convert every node to model of type T. When this is not possible an error is thrown.

					complete { try nodeArray.map {try T($0)} }
				default:
					complete {
						throw FaroError.noModelFor(call: call, inJson: rootNode)
					}
				}
			case .failure(let error):
				complete {throw error}
			default:
				complete {throw FaroError.general}
			}
		}
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
