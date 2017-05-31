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

For your unit tests create a singleton that you can use

```
class StoreUnitTests: CoreDataUnitTest {
	static let sharedInstance = StoreUnitTests()

	init(){
		super.init(modelName:"ModelName")
	}
}
```
*/

open class CoreDataUnitTest: NSObject {

	fileprivate let  storeType = NSInMemoryStoreType

	let modelName: String

	public init(modelName: String) {
		self.modelName = modelName
	}

	open lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

	fileprivate lazy var applicationDocumentsDirectory: URL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls.last!
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

			try coordinator.addPersistentStore(ofType: self.storeType, configurationName: nil, at: sqliteURL, options: nil)
		} catch {
			var dict = [String: Any]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as Any
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as Any

			dict[NSUnderlyingErrorKey] = error
			print("Unresolved error \(error)")
			abort()
		}

		return coordinator
	}()
}
