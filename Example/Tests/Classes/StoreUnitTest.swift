//
//  File.swift
//  AirRivet
//
//  Created by Stijn Willems on 03/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AirRivet

/**
Every unit test class should have its own managedObjectContext.
Look at CoreDataEntitySpec for an example.
*/

class StoreUnitTests: CoreDataUnitTest {

	init(){
		super.init(modelName:"Model")
	}
}