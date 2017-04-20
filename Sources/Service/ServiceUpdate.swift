//
//  ServiceUpdate.swift
//  Pods
//
//  Created by Stijn Willems on 20/04/2017.
//
//

import Foundation

class ServiceUpdate<T>: Service <T> where T: JSONDeserializable & Deserializable & JSONUpdatable {

	func updateSingle(_ singleModel: T,complete: @escaping(@escaping () throws -> Void) -> Void) {
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
						let error = FaroError.noModelFor(call: call, inJson: rootNode)
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
					let error = FaroError.invalidDeprecatedResult(call: call, resultString: "\(result)")
					self?.handleError(error)
					throw error
				}
			}
		}
	}

}


class ServiceUpdateCollection<T>: Service <T> where T: JSONDeserializable & Deserializable & JSONUpdatable & Linkable {

	func updateCollection(_ collection: [T],complete: @escaping(@escaping () throws -> Void) -> Void) {
		let call = self.call
		deprecatedService.performJsonResult(call, autoStart: autoStart) { [weak self](result: DeprecatedResult<T>) in
			switch result {

			case .json(let json):
				let rootNode = call.rootNode(from: json)

				switch rootNode {
				case .nodeArray(let nodeArray):
					guard let nodeArray = nodeArray as? [[String: Any]] else {

						complete {
							let error = FaroError.noModelFor(call: call, inJson: rootNode)
							self?.handleError(error)
							throw error
						}
						return
					}
					// Update Model with nodeObject. When this is not possible an error is thrown.
					complete {
						for node in nodeArray {
							let modelToUpdate = collection.first? {$0.ma}
							try model.update(node)
						}
					}
				default:
					complete { [weak self] in
						let error = FaroError.noModelFor(call: call, inJson: rootNode)
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
					let error = FaroError.invalidDeprecatedResult(call: call, resultString: "\(result)")
					self?.handleError(error)
					throw error
				}
			}
		}
	}
	
}
