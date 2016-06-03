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

class CoreDataEntitySpec: QuickSpec {

	static let context = StoreUnitTests().managedObjectContext
	class Mock : MockCoreDataEntity {
		class  override func managedObjectContext() -> NSManagedObjectContext? {
			return CoreDataEntitySpec.context
		}
	}

	override func spec() {
		describe("CoreDataEntity") {

			let context  = CoreDataEntitySpec.context
			beforeEach{
				context.reset()
			}

			it("Create instanse with username") {
				let entity = try! CoreDataEntity(json: ["username": "Fons"], managedObjectContext: context)
				expect(entity.username).to(equal("Fons"))
			}

			it("should fetch an existing object") {
				let json = ["uniqueValue":"unique id", "username": "Fons"]

				let entity = try! CoreDataEntity(json: json, managedObjectContext: context)

				let sameEntity = try! CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: context)

				expect(entity.objectID).to(equal(sameEntity!.objectID))

				let fetch = NSFetchRequest(entityName: "CoreDataEntity")
				let allEntities = try! context.executeFetchRequest(fetch) as! [CoreDataEntity]

				expect(allEntities).to(haveCount(1))
			}

			it("should not throw when no instance is found", closure: {
				let json = ["uniqueValue":"unique id", "username": "Fons"]

				let entity = try! CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: context)
				expect(entity).to(beNil())
			})

			it("should throw when more then one instance is found", closure: {
				let json = ["uniqueValue":"1"]
				let _ = try! CoreDataEntity(json:json , managedObjectContext: context)
				let _ = try! CoreDataEntity(json: json, managedObjectContext: context)

				expect(expression: { try CoreDataEntity.lookupExistingObjectFromJSON(json, managedObjectContext: context)}).to(throwError{ (error) in
					switch error {
					case MapError.EnityShouldBeUniqueForJSON(json: _, typeName: _):
						break
					default:
						XCTFail("Should not throw \(error)")
					}
					})
			})

			it("should throw when json does not contain unqique value") {
				expect(expression: { try CoreDataEntity.lookupExistingObjectFromJSON(["rubbish json":"something"], managedObjectContext: context)}).to(throwError{ (error) in
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