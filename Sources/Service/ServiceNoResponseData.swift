//
//  ServiceNoResponseData.swift
//  Pods
//
//  Created by Stijn Willems on 24/04/2017.
//
//

import Foundation

open class ServiceNoResponseData {

	let deprecatedService: DeprecatedService
	let call: Call
	let autoStart: Bool

	public init(call: Call, autoStart: Bool = true, deprecatedService: DeprecatedService = FaroSingleton.shared) {
		self.deprecatedService = deprecatedService
		self.call = call
		self.autoStart = autoStart
	}

	// MARK: Requests that expects NO JSON in response

	open func send(complete: @escaping(@escaping () throws -> Void) -> Void) {
		let call = self.call

		deprecatedService.performWrite(call, autoStart: autoStart) {[weak self] (result: WriteResult) in
			switch result {
			case .ok:
				complete {}
			case .failure(let error):
				complete { [weak self] in
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
