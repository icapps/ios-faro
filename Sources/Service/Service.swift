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
open class Service<T> where T: JSONDeserializable & Deserializable {

	private let deprecatedService: DeprecatedService
	private let call: Call
	private let autoStart: Bool

	init(call: Call, autoStart: Bool, deprecatedService: DeprecatedService = FaroDeprecatedSingleton.shared) {
		self.deprecatedService = deprecatedService
		self.call = call
		self.autoStart = autoStart
	}

	// MARK: Requests that expect a JSON response

	open func single(complete: @escaping(() throws -> (T)) -> Void) {
		deprecatedService.performJsonResult(call, autoStart: autoStart) {[unowned self] (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = self.call.rootNode(from: json)

				switch rootNode {
				case .nodeObject(let node):
					// Convert node to model of type T. When this is not possible an error is thrown.
					complete {try T(node)}
				default:
					complete { [unowned self] in
						throw FaroError.noModelFor(call: self.call, inJson: rootNode)
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
	open func collection(complete: @escaping (() throws -> [T]) -> Void)  {
		deprecatedService.performJsonResult(call, autoStart: autoStart) { (result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = self.call.rootNode(from: json)

				switch rootNode {
				case .nodeArray(let nodeArray):
					guard let nodeArray = nodeArray as? [[String: Any]] else {
						complete { [unowned self] in
							throw FaroError.noModelFor(call: self.call, inJson: rootNode)
						}
						return
					}

					// Convert every node to model of type T. When this is not possible an error is thrown.

					complete { try nodeArray.map {try T($0)} }
				default:
					complete { [unowned self] in
						throw FaroError.noModelFor(call: self.call, inJson: rootNode)
					}
				}
			case .failure(let error):
				complete {throw error}
			default:
				complete {throw FaroError.general}
			}
		}
	}

	// MARK: Requests that expect no JSON in response

	// TODO: add write functions

}
