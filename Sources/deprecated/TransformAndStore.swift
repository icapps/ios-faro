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

public class TransformAndStore<Rivet: EnvironmentConfigurable>: TransformJSON {

	public override init() {
		super.init()
	}

	override public func foundationObjectFromData(data: NSData, rootKey: String?, mitigator: ResponseMitigatable) throws -> AnyObject  {
		try toFile(data, contextPath: Rivet.contextPath())
		return try super.foundationObjectFromData(data, rootKey: rootKey, mitigator: mitigator)
	}
}

/**
Simular as `TransformAndStore` but for use with CoreData objects.
*/

public class TransformAndStoreCoreData<Rivet: EnvironmentConfigurable>: TransformCoreData {

	public override init() {
		super.init()
	}
	
	override public func foundationObjectFromData(data: NSData, rootKey: String?, mitigator: ResponseMitigatable) throws -> AnyObject  {
		try toFile(data, contextPath: Rivet.contextPath())
		return try super.foundationObjectFromData(data, rootKey: rootKey, mitigator: mitigator)
	}

}

private func toFile(data: NSData, contextPath: String) throws {
	let file = getDocumentsDirectory().stringByAppendingPathComponent("\(contextPath).json")
	let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
	try jsonString.writeToFile(file, atomically: false, encoding: NSUTF8StringEncoding)
}

private func getDocumentsDirectory() -> NSString {
	let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
	let documentsDirectory = paths[0]
	return documentsDirectory
}