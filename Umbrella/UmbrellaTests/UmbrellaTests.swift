//
//  UmbrellaTests.swift
//  UmbrellaTests
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import XCTest
@testable import Umbrella

class MockServerparameters: ServiceParameter {
	var serverUrl = "https://api.parse.com/1/classes/"
}
class UmbrellaTests: XCTestCase {
    
	
    func testExposedClassesInitializastions() {
        let test = RequestController(serviceParameters: MockServerparameters())
		let wait = TestWait()
		let exp = "testExposedClassesInitializastions"
		wait.expectations = [exp]
		
		test.sendRequest { (response) -> () in
			wait.fulFillExpectation(exp)
		}
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
		
    }
    
}
