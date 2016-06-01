//
//  AGCStore.swift
//  ios_agc_reference
//
//  Created by Stijn Willems on 25/05/16.
//  Copyright © 2016 iCapps. All rights reserved.
//

import Foundation

import CoreData


/**
Creates a sqlite store named `modelName.sqlite` that can be found in the application bundle documents folder.
*/

public class CoreDataPopulator: NSObject {

	var storeType = NSSQLiteStoreType
	let modelName: String


	/**
	Initialazes a convinience class for dealing with CoreData.
	- parameter modelName: name of youe model.
	*/
	init(modelName: String) {
		self.modelName = modelName
		super.init()
	}

	private lazy var applicationDocumentsDirectory: NSURL = {

		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
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

			let options = [NSMigratePersistentStoresAutomaticallyOption: true,
			               NSInferMappingModelAutomaticallyOption: true,
			               NSSQLitePragmasOption:["journal_mode": "DELETE"] ] //NSSQLitePragmasOption to disable core data caching
			try coordinator.addPersistentStoreWithType(self.storeType, configuration: nil, URL: sqliteURL, options: options)
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

	public lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

	// MARK: - Core Data Saving support

	public func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
}