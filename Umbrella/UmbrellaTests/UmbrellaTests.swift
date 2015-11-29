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
	
	var score: Int?
	var cheatMode: Bool?
	var playerName: String?
	
	required init(json: AnyObject) {
		importFromJSON(json)
	}
	
	
	static func contextPath() -> String {
		return "GameScore"
	}
	
	func body()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}
	func importFromJSON(json: AnyObject) {
		if let json = json as? NSDictionary {
			score = json["score"] as? Int
			cheatMode = json["cheatMode"] as? Bool
			playerName = json["playerName"] as? String
		}
	}
	
}

class UmbrellaTests: XCTestCase {
    
	
    func testSave() {
        let test = RequestController(serviceParameters: MockServerparameters())
		let wait = TestWait()
		let exp = "testExposedClassesInitializastions"
		wait.expectations = [exp]
		
		let gameScore = GameScore(json: [
			"score": 1337,
			"cheatMode": false,
			"playerName": "Sean Plott"
			])
		let response: (response: GameScore) -> () = {(response: GameScore) -> () in
			wait.fulFillExpectation(exp)
		}
		
		test.save(gameScore, completion: response)
		
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
    }
	
	func testRetreive() {
		let test = RequestController(serviceParameters: MockServerparameters())
		let wait = TestWait()
		let exp = "testExposedClassesInitializastions"
		wait.expectations = [exp]
		
	
		let response: (response: [GameScore]) -> () = {(response: [GameScore]) -> () in
			XCTAssertGreaterThan(response.count, 1)
		
			wait.fulFillExpectation(exp)
		}
		
		test.retrieve(response)
		
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
	}
    
}
