//
//  CoreDataEntitySpec.swift
//  AirRivet
//
//  Created by Stijn Willems on 19/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreData

@testable import AirRivet_Example


// MARK: - Specs

class CoreDataEntitySpec: QuickSpec {

	override func spec() {
		describe("Create core data") {

			let coreDataController = CoreDataController.sharedInstance
			coreDataController.storeType = NSInMemoryStoreType
			beforeEach({
				coreDataController.managedObjectContext.reset()
			})

			it("Create instanse with username") {
				let entity = try! CoreDataEntity(json: ["username": "Fons"], managedObjectContext: coreDataController.managedObjectContext)
				expect(entity.username).to(equal("Fons"))
			}

			it("should fetch an existing object") {
				let json = ["CoreDataEntityObjectId":"unique id", "username": "Fons"]
				let entity = try! CoreDataEntity(json: json, managedObjectContext: coreDataController.managedObjectContext)

				let sameEntity = try! CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: coreDataController.managedObjectContext)

				expect(entity.objectID).to(equal(sameEntity?.objectID))

				//TODO: fetch all entities and see if there are only 1

				//TODO: let init fail if there is a unique object present

				

			}
		}
	}

}