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

open class CoreDataSQLitePopulator: NSObject {

	var storeType = NSSQLiteStoreType
	let modelName: String


	/**
	Initialazes a convinience class for dealing with CoreData.
	- parameter modelName: name of youe model.
	*/
	public init(modelName: String) {
		self.modelName = modelName
		super.init()
	}

	open lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

	fileprivate lazy var applicationDocumentsDirectory: URL = {

		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1]
	}()

	fileprivate lazy var managedObjectModel: NSManagedObjectModel = { [unowned self] in
		let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()

	/**
	- returns: persistentStoreCoordinator that does not use caching. This is needed if we want the data to be
	*/
	fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {[unowned self] in
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let sqliteURL = self.applicationDocumentsDirectory.appendingPathComponent("\(self.modelName).sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {

			let options = [NSMigratePersistentStoresAutomaticallyOption: true,
			               NSInferMappingModelAutomaticallyOption: true,
			               NSSQLitePragmasOption:["journal_mode": "DELETE"] ] as [String : Any] //NSSQLitePragmasOption to disable core data caching
			try coordinator.addPersistentStore(ofType: self.storeType, configurationName: nil, at: sqliteURL, options: options)
		} catch {
			var dict = [String: Any]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as Any
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as Any

			dict[NSUnderlyingErrorKey] = error as Error
			print("Unresolved error")
			abort()
		}

		return coordinator
	}()



	// MARK: - Core Data Saving support

	open func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				NSLog("Unresolved error \(error)")
				abort()
			}
		}
	}
}
