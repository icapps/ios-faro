//
//  CoreDataUnitTest.swift
//  ios_agc_reference
//
//  Created by Stijn Willems on 26/05/16.
//  Copyright © 2016 iCapps. All rights reserved.
//

import Foundation

import CoreData

/**
Simple core data controller just to create a model that we can reuse.
*/

//TODO: ARA-44 Move to AirRivet or icapps/swift-core-data-populator

class CoreDataUnitTest: NSObject {

	private let  storeType = NSInMemoryStoreType

	let modelName: String

	init(modelName: String) {
		self.modelName = modelName
	}

	private lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls.last!
	}()

	private lazy var managedObjectModel: NSManagedObjectModel = { [unowned self] in
		let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	/**
	- returns: persistentStoreCoordinator that does not use caching. This is needed if we want the data to be
	*/
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {[unowned self] in
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let sqliteURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.modelName).sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {

			try coordinator.addPersistentStoreWithType(self.storeType, configuration: nil, URL: sqliteURL, options: nil)
		} catch {
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason

			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}

		return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

}