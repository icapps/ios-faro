//
//  GameScoreSpec.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Quick
import Nimble
import AirRivet
import Foundation

// MARK: - Mocks

class Mock: Environment, Mockable, Transformable {
	
    var serverUrl = ""
	var request = NSMutableURLRequest()

	func shouldMock() -> Bool {
		return true
	}
    
}

class MockGameScore: GameScore {

	override class func contextPath() -> String {
		return "gameScoreArray"
	}

	override class func environment() -> protocol<Environment, Mockable, Transformable> {
		return Mock ()
	}
    
}

// MARK: - Specs

class GameScoreSpec: QuickSpec {
    override func spec() {
        describe("GameScore") {

			it ("Should be synchronous because we implement the Mockable protocol") {
				try! Air.retrieve(succeed: { (response: [MockGameScore]) in
					expect(response).to(haveCount(5))
				})
			}

			it("all gamescores should be parsed", closure: {
				let expected = ["Bob", "Daniel", "Hans", "Stijn", "Jelle"]
				try! Air.retrieve(succeed: { (response: [MockGameScore]) in
					for i in 0..<response.count {
						let gameScore = response[i]
						expect(gameScore.playerName).to(equal(expected[i]))
					}
				})

			})
            
            it("save succeeds by mocking") {
				var success = false
				let gameScore = try! MockGameScore(json: ["":""])
				gameScore.score = 1
				gameScore.cheatMode = false
				gameScore.playerName = "Foo"
				
				try! Air.save(gameScore, succeed: { (response) in
					success = true
                })
				expect(success).to(equal(true))
            }

			it("retrieve a single gamescore by objectID"){
				var result = try! MockGameScore(json: ["":""])
				let objectId = "1275"
				try! Air.retrieveWithUniqueId(objectId, succeed: { (response) in
					result = response
                }, fail: { (error) in
                    XCTFail("Failed with \(error)")
				})

				expect(result.objectId).to(equal(objectId))
			}

        }
    }
}
