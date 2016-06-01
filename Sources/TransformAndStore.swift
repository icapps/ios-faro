//
//  TransformAndStore.swift
//  Pods
//
//  Created by Stijn Willems on 01/06/16.
//
//

import Foundation


class TransformAndStore<Rivet: EnvironmentConfigurable>: TransformJSON {

	override func foundationObjectFromData(data: NSData, rootKey: String?, mitigator: ResponseMitigatable) throws -> AnyObject  {
		try toFile(data)
		return try super.foundationObjectFromData(data, rootKey: rootKey, mitigator: mitigator)
	}

	private func toFile(data: NSData) throws {
		let file = getDocumentsDirectory().stringByAppendingPathComponent("\(Rivet.contextPath()).json")
		let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
		try jsonString.writeToFile(file, atomically: false, encoding: NSUTF8StringEncoding)
	}

	private func getDocumentsDirectory() -> NSString {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}

class TransformAndStoreCoreData<Rivet: EnvironmentConfigurable>: TransformCoreData {

	override func foundationObjectFromData(data: NSData, rootKey: String?, mitigator: ResponseMitigatable) throws -> AnyObject  {
		try toFile(data)
		return try super.foundationObjectFromData(data, rootKey: rootKey, mitigator: mitigator)
	}

	private func toFile(data: NSData) throws {
		let file = getDocumentsDirectory().stringByAppendingPathComponent("\(Rivet.contextPath()).json")
		let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
		try jsonString.writeToFile(file, atomically: false, encoding: NSUTF8StringEncoding)
	}

	private func getDocumentsDirectory() -> NSString {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}