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

			let coreDataController = CoreDataController()
			coreDataController.storeType = NSInMemoryStoreType
			beforeEach({
				coreDataController.managedObjectContext.reset()
			})


			it("Create instanse with username") {
				let entity = try! CoreDataEntity(json: ["username": "Fons"], managedObjectContext: coreDataController.managedObjectContext)
				expect(entity.username).to(equal("Fons"))
			}

			context("unique behaviour") {
				it("should fetch an existing object") {
					let json = ["uniqueValue":"unique id", "username": "Fons"]

					let entity = try! CoreDataEntity(json: json, managedObjectContext: coreDataController.managedObjectContext)

					let sameEntity = try! CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: coreDataController.managedObjectContext)

					expect(entity.objectID).to(equal(sameEntity!.objectID))

					let fetch = NSFetchRequest(entityName: "CoreDataEntity")
					let allEntities = try! coreDataController.managedObjectContext.executeFetchRequest(fetch) as! [CoreDataEntity]

					expect(allEntities).to(haveCount(1))
				}

				it("should not throw when no instance is found", closure: {
					let json = ["uniqueValue":"unique id", "username": "Fons"]

					let entity = try! CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: coreDataController.managedObjectContext)
					expect(entity).to(beNil())
				})

				it("should throw when more then one instance is found", closure: {
					let json = ["uniqueValue":"1"]
					let _ = try! CoreDataEntity(json:json , managedObjectContext: coreDataController.managedObjectContext)
					let _ = try! CoreDataEntity(json: json, managedObjectContext: coreDataController.managedObjectContext)

					expect(expression: { try CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: coreDataController.managedObjectContext)}).to(throwError{ (error) in
						switch error {
						case MapError.EnityShouldBeUniqueForJSON(json: _, typeName: _):
							break
						default:
							XCTFail("Should not throw \(error)")
						}
						})
				})
				
				it("should throw when json doesn not contain unqique value") {
					expect(expression: { try CoreDataEntity.lookupExistingObjectFromJSON(["rubbish json":"something"], managedObjectContext: coreDataController.managedObjectContext)}).to(throwError{ (error) in
						switch error {
						case MapError.JSONHasNoUniqueValue(json: _):
							break
						default:
							XCTFail("Should not throw \(error)")
						}
						})
				}
			}

		}
	}

}