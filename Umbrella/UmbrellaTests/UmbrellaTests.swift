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
	
	var test: RequestController!
	var wait: TestWait!
	
	let gameScore = GameScore(json: [
		"score": 1337,
		"cheatMode": false,
		"playerName": "Sean Plott"
		])
	
	override func setUp() {
		test = RequestController(serviceParameters: PlaygroundService<GameScore>())
		wait = TestWait()
		super.setUp()
	}
    func testSave() {
		
		let exp = "testSave"
		wait.expectations = [exp]
		
		let response: (response: GameScore) -> () = {[unowned self](response: GameScore) -> () in
			XCTAssertNotNil(response.objectId)
			self.wait.fulFillExpectation(exp)
		}
		
		try! test.save(gameScore, completion: response)
		
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
    }
	
	func testRetreive_Array() {
		let exp = "testRetreive_Array"
		wait.expectations = [exp]
		
	
		let response: (response: [GameScore]) -> () = {[unowned self](response: [GameScore]) -> () in
			XCTAssertGreaterThan(response.count, 1)
		
			self.wait.fulFillExpectation(exp)
		}
		
		test.retrieve(response)
		
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
	}
	
	func testRetreive_Object() {
		let objectId = "ta40DRgRAn"
		let exp = "testRetreive_Object"
		wait.expectations = [exp]
		
		
		let response: (response: GameScore) -> () = {[unowned self](response: GameScore) -> () in
			XCTAssertNotNil(response.score)
			XCTAssertNotNil(response.cheatMode)
			XCTAssertNotNil(response.playerName)
			XCTAssertEqual(response.objectId, objectId)
			
			self.wait.fulFillExpectation(exp)
		}
		
		test.retrieve(objectId, completion: response)
		
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
	}
	
	func testSave_Throws() {
		let exp = "testSave_Throws"
		wait.expectations = [exp]
		
		let response: (response: GameScore) -> () = {(response: GameScore) -> () in
			XCTFail("We should not complete but throw")
		}
		
		do {
			try test.save(MockUnsavableGame(json: []), completion: response)
		}catch  {
			wait.fulFillExpectation(exp)
		}
		
		wait.waitUntillFinishWithTimeout(2) { (success, unfulFilledExpectations) -> () in
			XCTAssertTrue(success, "\(unfulFilledExpectations)")
		}
	}
}

//MARK: Mocks

class PlaygroundService <BodyType: BaseModel>: ServiceParameter {
	var serverUrl = "https://api.parse.com/1/classes/"
	var request: NSMutableURLRequest {
		let URL = NSURL(string: "\(serverUrl)\(BodyType.contextPath())")
		let request = NSMutableURLRequest(URL: URL!)
		
		// Headers
		
		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		return request
	}
}

class MockErrorController: ErrorController {
	required init(){
		
	}
	func requestBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
}

class GameScore: BaseModel {
	
	var score: Int?
	var cheatMode: Bool?
	var playerName: String?
	
	var objectId: String?
	var errorController: ErrorController
	
	required init(json: AnyObject) {
		errorController = MockErrorController()
		importFromJSON(json)
	}
	
	//MARK: BaseModel Protocol Type
	static func contextPath() -> String {
		return "GameScore"
	}
	
	static func serviceParameters() -> ServiceParameter {
		return PlaygroundService<GameScore>()
	}
	
	//MARK: BaseModel Protocol Instance
	func body()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}
	func importFromJSON(json: AnyObject) {
		if let json = json as? NSDictionary {
			objectId = json["objectId"] as? String
			score = json["score"] as? Int
			cheatMode = json["cheatMode"] as? Bool
			playerName = json["playerName"] as? String
		}
	}
}

class MockUnsavableGame: BaseModel {
	
	var objectId: String?
	var errorController: ErrorController
	
	required init(json: AnyObject) {
		errorController = MockErrorController()
		importFromJSON(json)
	}
	
	
	static func contextPath() -> String {
		return "Unsavable"
	}
	
	static func serviceParameters() -> ServiceParameter {
		return PlaygroundService<MockUnsavableGame>()
	}
	
	func body()-> NSDictionary? {
		return nil
	}
	func importFromJSON(json: AnyObject) {
		
	}
	
}
