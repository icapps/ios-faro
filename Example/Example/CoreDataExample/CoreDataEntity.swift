//
//  CoreDataEntity.swift
//  AirRivet
//
//  Created by Stijn Willems on 19/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import CoreData

import AirRivet

class CoreDataEntity: NSManagedObject, EnvironmentConfigurable, Parsable, Mitigatable, Transformable {

	// MARK: - Init

	required init(json: AnyObject, managedObjectContext: NSManagedObjectContext? = CoreDataEntity.managedObjectContext()) throws {
		let entity = NSEntityDescription.entityForName("CoreDataEntity", inManagedObjectContext: managedObjectContext!)
		super.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
		try self.map(json)
	}

	// MARK: - Parsable

	func toDictionary()-> NSDictionary? {
		return ["CoreDataEntityObjectId": objectId!]
	}

	func map(json: AnyObject) throws {
		if let objectId = json["CoreDataEntityObjectId"] as? String {
			self.objectId = objectId
		}
	}

	static func rootKey() -> String? {
		return nil
	}

	class func managedObjectContext() -> NSManagedObjectContext? {
		return CoreDataController.sharedInstance.managedObjectContext
	}

	static func environment() -> protocol<Environment, Mockable> {
		return EnvironmentParse<CoreDataEntity>()
	}

	static func contextPath() -> String {
		return "CoreDataEntity"
	}

	// MARK: - Mitigatable

	class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	class func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	//MARK: - Transfromable
	class func transform() -> TransformJSON {
		return TransformCoreData()
	}
}
