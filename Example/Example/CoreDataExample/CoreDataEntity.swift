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
		return ["CoreDataEntityObjectId": objectId!, "username": username!]
	}

	func map(json: AnyObject) throws {
		if let objectId = json["CoreDataEntityObjectId"] as? String {
			self.objectId = objectId
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

		guard let managedObjectContext = managedObjectContext else {
			return nil
		}

		let uniqueKey = json["CoreDataEntityObjectId"] as! String
		let fetchrequest = NSFetchRequest(entityName: "CoreDataEntity")
		let predicate = NSPredicate(format: "objectId == %@", uniqueKey)
		fetchrequest.predicate = predicate

		let entities = try managedObjectContext.executeFetchRequest(fetchrequest) as! [CoreDataEntity]
		if !entities.isEmpty && entities.count == 1 {
				return autocast(entities.first)
		}else {
			throw ResponseError.GeneralWithResponseJSON(statuscode: 205, responseJSON: json)
		}
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

