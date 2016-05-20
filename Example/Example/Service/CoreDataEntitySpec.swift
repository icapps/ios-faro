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
import AirRivet

@testable import AirRivet_Example

class MockCoreDataEntity: CoreDataEntity {

	// MARK: - Mitigatable

	class override func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}

	class override func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}
}

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

				let fetch = NSFetchRequest(entityName: "CoreDataEntity")
				let allEntities = try! coreDataController.managedObjectContext.executeFetchRequest(fetch) as! [CoreDataEntity]

				expect(allEntities).to(haveCount(1))

				//TODO: let init fail if there is a unique object present

				//TODO: Test with transformer

			}
		}
	}

}