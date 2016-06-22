//
//  CoreDataPopulated.swift
//  ios_agc_reference
//
//  Created by Stijn Willems on 27/05/16.
//  Copyright © 2016 iCapps. All rights reserved.
//

import Foundation
import CoreData

/**
Reuses a sqlite model with `modelName` that can be found in your application bundle (Add it to your xcode project).

Use the `CoreDataPopulator` to create the _sqlite_ file with `modelName`.

*/

enum CoreDataFromPopulatedSQLiteError: ErrorType {
	case MissingSQLiteFile(fileName: String)
}

public class CoreDataFromPopulatedSQLite: NSObject {

	var storeType = NSSQLiteStoreType
	let modelName: String
	let options = [NSMigratePersistentStoresAutomaticallyOption: true,
	               NSInferMappingModelAutomaticallyOption: true]

	/**
	Initialazes a convinience class for dealing with CoreData.
	- parameter modelName: name of youe model. 
	*/
	public init(modelName: String) {
		self.modelName = modelName
		super.init()
	}

	public lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()


	private lazy var applicationDocumentsDirectory: NSURL = {

		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls.last!
	}()

	private lazy var managedObjectModel: NSManagedObjectModel = { [unowned self] in
		let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
		}()

	/**
	- returns: persistentStoreCoordinator with pre filled sqlite.
	*/
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = { [unowned self] in
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

		var failureReason = "There was an error creating or loading the application's saved data."

		do {

			let sqliteURL = try self.usePrefilledSQLLiteFromApplicationBundle()
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteURL, options: self.options)

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

	private func usePrefilledSQLLiteFromApplicationBundle() throws -> NSURL  {
		let sqliteURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(modelName).sqlite")

		let fileManager = NSFileManager.defaultManager()
		if !fileManager.fileExistsAtPath(sqliteURL.path!){
			print("🗼 moving sqlite database into place for reuse.")
			guard let bundleUrl = NSBundle.mainBundle().URLForResource(modelName, withExtension: ".sqlite") else {
				print("💣 we could not find \(modelName).sqlite in your application bundle. Make sure it is added to the target and in your project.")
				throw CoreDataFromPopulatedSQLiteError.MissingSQLiteFile(fileName: "\(modelName).sqlite")
			}

			do {
				try fileManager.copyItemAtURL(bundleUrl, toURL: sqliteURL)

			}catch {
				print("💣 failed to preload database. Using database without data.")
				print("💣 error \(error)")
			}
		}else {
			print("🚀We are reusing previous sqlite data")
		}
		return sqliteURL
	}

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