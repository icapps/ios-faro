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
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}

	// MARK: - Init

	required init(json: Any, managedObjectContext: NSManagedObjectContext? = CoreDataEntity.managedObjectContext()) throws {
		let entity = NSEntityDescription.entity(forEntityName: "CoreDataEntity", in: managedObjectContext!)
		super.init(entity: entity!, insertInto: managedObjectContext)
		try self.map(json)
	}

	// MARK: - Parsable

	func toDictionary() -> NSDictionary? {
		return ["uniqueValue": uniqueValue!, "username": username!]
	}

	func map(_ json: Any) throws {
		guard let jsonDict = json as? [String: Any] else {
			throw ResponseError.generalWithResponseJSON(statuscode: 1000, responseJSON: json)
		}
		if let uniqueValue = jsonDict["uniqueValue"] as? String {
			self.uniqueValue = uniqueValue
		}

		if let username = jsonDict["username"] as? String {
			self.username = username
		}
	}

	static func rootKey() -> String? {
		return "results"
	}

	class func managedObjectContext() -> NSManagedObjectContext? {
		return CoreDataController.sharedInstance.managedObjectContext
	}

	class func environment() -> Environment & Mockable {
		return EnvironmentParse<CoreDataEntity>()
	}

	static func contextPath() -> String {
		return "CoreDataEntity"
	}

	static func lookupExistingObjectFromJSON(_ json: Any, managedObjectContext: NSManagedObjectContext?) throws -> Self? {
		guard let jsonDict = json as? [String: Any] else {
			throw ResponseError.generalWithResponseJSON(statuscode: 1000, responseJSON: json)
		}

		guard let managedObjectContext = managedObjectContext else {
			return nil
		}

		return try fetchInCoreDataFromJSON(jsonDict, managedObjectContext: managedObjectContext, entityName: "CoreDataEntity", uniqueValueKey: "uniqueValue")
	}

	// MARK: - Mitigatable

	class func responseMitigator() -> ResponseMitigatable & Mitigator {
		return MitigatorDefault()
	}

	class func requestMitigator() -> RequestMitigatable & Mitigator {
		return MitigatorDefault()
	}

	// MARK: - Transfromable
	class func transform() -> TransformJSON {
		return TransformCoreData()
	}
}
