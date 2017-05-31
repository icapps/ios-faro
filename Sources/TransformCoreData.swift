//
//  TransformJSONerCoreData.swift
//  Pods
//
//  Created by Stijn Willems on 19/05/16.
//
//

import Foundation

/**
Because Core Data is not thread safe we have to provide a class that can handle this.

You could provide a class that performs operations on the background queue here. For now we only dispatch to the main queue.
*/

open class TransformCoreData: TransformJSON {


	open override func transform<Rivet: Parsable & Mitigatable>(_ data: Data, succeed: @escaping (Rivet)->()) throws {
		dispatch.async.main {
			do {
				try super.transform(data, succeed: succeed)
			}catch {
				print("💣 Transform failed with error: \(error)")
			}
		}
	}

	open override func transform<Rivet: Parsable & Mitigatable>(_ data: Data, succeed: @escaping ([Rivet])->()) throws {
		dispatch.async.main {
			do {
				try super.transform(data, succeed: succeed)
			}catch {
				print("💣 Transform failed with error: \(error)")
			}
		}
	}
}
