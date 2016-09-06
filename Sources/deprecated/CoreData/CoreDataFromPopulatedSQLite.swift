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
    let version: String
    
    /**
     Initialazes a convinience class for dealing with CoreData.
     - parameter modelName: name of youe model. 
     */
    public init(modelName: String, version: String) {
        
        self.modelName = modelName
        self.version = version
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = urls.last!
        self.sqliteURL = documentsDirectory.URLByAppendingPathComponent("\(version)_\(modelName).sqlite")
        super.init()
    }
    
    public lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
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
    
    private let sqliteURL: NSURL
    private let fileManager = NSFileManager.defaultManager()
    
    /**
     - returns: Yes of we can reuse the sqlite file in the documents folder.
     */
    
    public func allModelNameSQLiteFilesInDocumentsFolder() -> [NSURL]? {
        
        if fileManager.fileExistsAtPath(sqliteURL.path!) {
            return [sqliteURL]
        } else {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let documentsDirectory = urls.last!
            do {
                if let filesNameInDocumentsDirectory: [NSURL] = try fileManager.contentsOfDirectoryAtURL(documentsDirectory, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles) {
                    let files = filesNameInDocumentsDirectory.map { $0 }
                    let modelFiles = files.filter { (element) -> Bool in
                        if let fileName = element.lastPathComponent {
                            return fileName.containsString(modelName)
                        }else {
                            return false
                        }
                    }
                    return modelFiles
                }
                
            }catch {
                print("Error retreiving files in documents with \(error)")
                return nil
            }
            return nil
        }
    }
    
    public func reuseSQLite() -> Bool {
        if let allModelNameSQLiteFiles = allModelNameSQLiteFilesInDocumentsFolder() {
            if allModelNameSQLiteFiles.count == 1 {
                let filename = allModelNameSQLiteFiles.first?.lastPathComponent
                if filename == "\(version)_\(modelName).sqlite" {
                    return true
                }else {
                    return false
                }
            }else {
                
                // Delete all files
                do {
                    for url in allModelNameSQLiteFiles {
                        try fileManager.removeItemAtURL(url)
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
    
    private func usePrefilledSQLLiteFromApplicationBundle() throws -> NSURL {
        
        if !reuseSQLite() {
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
    public func saveContext() {
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