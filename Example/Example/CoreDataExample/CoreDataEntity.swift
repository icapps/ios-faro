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

	/**
	You should override this method. Swift does not inherit the initializers from its superclass.
	*/
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}

	// MARK: - Init

	required init(json: AnyObject, managedObjectContext: NSManagedObjectContext? = CoreDataEntity.managedObjectContext()) throws {
		let entity = NSEntityDescription.entityForName("CoreDataEntity", inManagedObjectContext: managedObjectContext!)
		super.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
		try self.map(json)
	}

	// MARK: - Parsable

	func toDictionary()-> NSDictionary? {
		return ["uniqueValue": uniqueValue!, "username": username!]
	}

	func map(json: AnyObject) throws {
		if let uniqueValue = json["uniqueValue"] as? String {
			self.uniqueValue = uniqueValue
		}

		if let username = json["username"] as? String {
			self.username = username
		}
	}

	static func rootKey() -> String? {
		return "results"
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

	static func lookupExistingObjectFromJSON(json: AnyObject, managedObjectContext: NSManagedObjectContext?) throws -> Self? {

		guard let managedObjectContext = managedObjectContext else  {
			return nil
		}

		return autocast(try fetchInCoreDataFromJSON(json, managedObjectContext: managedObjectContext, entityName: "CoreDataEntity", uniqueValueKey: "uniqueValue"))
	}

	// MARK: - Mitigatable

	class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorDefault()
	}

	class func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorDefault()
	}

	//MARK: - Transfromable
	class func transform() -> TransformJSON {
		return TransformCoreData()
	}
}
