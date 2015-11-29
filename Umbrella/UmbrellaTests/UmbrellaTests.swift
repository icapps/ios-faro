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
	var request: NSMutableURLRequest {
		let URL = NSURL(string: "\(serverUrl)GameScore")
		let request = NSMutableURLRequest(URL: URL!)
		request.HTTPMethod = "POST"
		
		// Headers
		
		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		return request
	}
}
class GameScore: BaseModel {
	private let bodyObject = [
		"score": 1337,
		"cheatMode": false,
		"playerName": "Sean Plott"
	]
	
	static func contextPath() -> String {
		return "GameScore"
	}
	
	func body()-> NSDictionary? {
		return bodyObject
	}
	
}

class UmbrellaTests: XCTestCase {
    
	
    func testExposedClassesInitializastions() {
        let test = RequestController<GameScore>(serviceParameters: MockServerparameters())
		let wait = TestWait()
		let exp = "testExposedClassesInitializastions"
		wait.expectations = [exp]
		
		test.saveBody(GameScore()) { (response) -> () in
			wait.fulFillExpectation(exp)
		}
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
		
    }
    
}
