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

class CoreDataSQLitePopulatorSpec: QuickSpec {
    
    class MockPopulatorWithSQLite : CoreDataFromPopulatedSQLite {
        override func allModelNameSQLiteFilesInDocumentsFolder() -> [NSURL]? {
            return [NSURL.fileURLWithPath("file:bla/1_Test.sqlite")]
        }
    }
    
    override func spec() {
        describe("CoreDataSQLitePopulatorSpec") {
            
            it("should reuse sqlite of the same version", closure: {
                let populator = MockPopulatorWithSQLite(modelName: "Test", version: "1")
                
                expect(populator.reuseSQLite()).to(beTrue())
            })
            
            //Add test for no prefix
            
        }
    }
    
}