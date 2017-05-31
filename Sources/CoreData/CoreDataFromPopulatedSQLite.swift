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

enum CoreDataFromPopulatedSQLiteError: Error {
	case missingSQLiteFile(fileName: String)
}

open class CoreDataFromPopulatedSQLite: NSObject {

	var storeType = NSSQLiteStoreType
	let modelName: String
	let options = [NSMigratePersistentStoresAutomaticallyOption: true,
	               NSInferMappingModelAutomaticallyOption: true]
    let version: String
    
    /**
     Initialazes a convinience class for dealing with CoreData.
     - parameter modelName: name of youe model. 
     */
    public init(modelName: String, version: String) {
        
        self.modelName = modelName
        self.version = version
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls.last!
        self.sqliteURL = documentsDirectory.appendingPathComponent("\(version)_\(modelName).sqlite")
        super.init()
	}

	open lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
    
    private lazy var managedObjectModel: NSManagedObjectModel = { [unowned self] in
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    /**
     - returns: persistentStoreCoordinator with pre filled sqlite.
     */
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = { [unowned self] in
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            
            let sqliteURL = try self.usePrefilledSQLLiteFromApplicationBundle()
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL as URL, options: self.options)
            
        } catch {
            
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

			dict[NSUnderlyingErrorKey] = error as Error
			print("Unresolved error")
			abort()

		}

		return coordinator
		}()

    private let sqliteURL: URL
    private let fileManager = FileManager.default
    
    /**
     - returns: Yes of we can reuse the sqlite file in the documents folder.
     */
    
    open func allModelNameSQLiteFilesInDocumentsFolder () -> [URL]? {
        
        if fileManager.fileExists(atPath: sqliteURL.path) {
            return [sqliteURL]
        } else {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls.last!
            do {
                if let filesNameInDocumentsDirectory: [URL] = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                    let files = filesNameInDocumentsDirectory.map{$0}
                    let modelFiles = files.filter({ (element) -> Bool in
                        return element.lastPathComponent.contains(modelName)
                    })
                    return modelFiles
                }
                
            }catch {
                print("Error retreiving files in documents with \(error)")
                return nil
            }
            return nil
        }
    }
    
    open func reuseSQLite() -> Bool {
        if let allModelNameSQLiteFiles = allModelNameSQLiteFilesInDocumentsFolder() {
            if allModelNameSQLiteFiles.count == 1 {
                let filename = allModelNameSQLiteFiles.first?.lastPathComponent
                if filename == "\(version)_\(modelName).sqlite" {
                    return true
                }else {
                    return false
                }
            }else {
                
                //Delete all files
                do {
                    for url in allModelNameSQLiteFiles {
                        try fileManager.removeItem(at: url)
                        print("😀 delete succeeded")
                    }
                }catch {
                    print("💣 error deleting file \(error)")
                }
                
                return false
            }
        }else {
            return false
        }
    }
    
	private func usePrefilledSQLLiteFromApplicationBundle() throws -> URL  {
		
		if !reuseSQLite(){
			print("🗼 moving sqlite database into place for reuse.")
			guard let bundleUrl = Bundle.main.url(forResource: modelName, withExtension: ".sqlite") else {
				print("💣 we could not find \(modelName).sqlite in your application bundle. Make sure it is added to the target and in your project.")
				throw CoreDataFromPopulatedSQLiteError.missingSQLiteFile(fileName: "\(modelName).sqlite")
			}

			do {
				try fileManager.copyItem(at: bundleUrl, to: sqliteURL)

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
				print("Unresolved error \(error)")
				abort()
			}
		}
	}
}
