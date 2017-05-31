//
//  TransformAndStore.swift
//  Pods
//
//  Created by Stijn Willems on 01/06/16.
//
//

import Foundation


/**
Used to transform data and store the JSON in a JSON file in the documents folder
*/

open class TransformAndStore<Rivet: EnvironmentConfigurable>: TransformJSON {

	public override init() {
		super.init()
	}

	override open func foundationObjectFromData(_ data: Data, rootKey: String?, mitigator: ResponseMitigatable) throws -> Any  {
		try toFile(data, contextPath: Rivet.contextPath())
		return try super.foundationObjectFromData(data, rootKey: rootKey, mitigator: mitigator)
	}
}

/**
Simular as `TransformAndStore` but for use with CoreData objects.
*/

open class TransformAndStoreCoreData<Rivet: EnvironmentConfigurable>: TransformCoreData {

	public override init() {
		super.init()
	}
	
	override open func foundationObjectFromData(_ data: Data, rootKey: String?, mitigator: ResponseMitigatable) throws -> Any  {
		try toFile(data, contextPath: Rivet.contextPath())
		return try super.foundationObjectFromData(data, rootKey: rootKey, mitigator: mitigator)
	}

}

private func toFile(_ data: Data, contextPath: String) throws {
	let file = getDocumentsDirectory().appendingPathComponent("\(contextPath).json")
	let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
	try jsonString.write(toFile: file, atomically: false, encoding: String.Encoding.utf8)
}

private func getDocumentsDirectory() -> NSString {
	let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
	let documentsDirectory = paths[0]
	return documentsDirectory as NSString
}
