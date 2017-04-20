//
//  ServiceUpdate.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

open class ServiceUpdate<T>: Service <T> where T: JSONDeserializable & Deserializable & JSONUpdatable {

	open func updateSingle(_ singleModel: T,complete: @escaping(@escaping () throws -> Void) -> Void) {
		let call = self.call
		deprecatedService.performJsonResult(call, autoStart: autoStart) { [weak self](result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeObject(let node):
					// Update Model with nodeObject. When this is not possible an error is thrown.
					complete {try singleModel.update(node)}
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

}


open class ServiceUpdateCollection<T>: Service <T> where T: JSONDeserializable & Deserializable & JSONUpdatable & Linkable & JSONMatchable {

	/// Updates every object in `collection` paramter with a json node in the response
	/// When you do not mind that the reponse contains nodes that are not in collection put parameter `allowMissingNodes` to true, default is false.
	open func updateCollection(_ collection: [T], allowMissingNodes: Bool = false, complete: @escaping(@escaping () throws -> Void) -> Void) {
		let call = self.call
		deprecatedService.performJsonResult(call, autoStart: autoStart) { [weak self](result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeArray(let nodeArray):
					guard let nodeArray = nodeArray as? [[String: Any]] else {

						complete {
							let error = FaroError.noModelOf(type: "\(T.self)", inJson: rootNode, call: call)
							self?.handleError(error)
							throw error
						}
						return
					}

					// Update Model with nodeObject. When this is not possible an error is thrown.
					complete { [weak self] in
						for node in nodeArray {
							if let modelToUpdate = (collection.first {$0.matchesJson(node)}) {
								try modelToUpdate.update(node)
							} else {
								let error = FaroError.noUpdateModelOf(type: "\(T.self)", ofJsonNode: node, call: call)
								self?.handleError(error)
								if !allowMissingNodes {
									throw error
								}
							}
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
	
}
