//
//  UmbrellaTests.swift
//  UmbrellaTests
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import XCTest
@testable import Umbrella

class UmbrellaTests: XCTestCase {
    
	
    func testExposedClassesInitializastions() {
        let test = SwiftFrameworks()
		
		test.doSomething()
		
		XCTAssertNotNil(test)
    }
    
}
