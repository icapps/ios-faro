//Here you can play around with the Umbrella framework to see if it works

import UIKit
import Umbrella
import XCPlayground

class UmbrellaPlaygroundServiceParameter<BodyType: BaseModel>: ServiceParameter {
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

class GameScore: BaseModel {
	
	var score: Int?
	var cheatMode: Bool?
	var playerName: String?
	var objectId: String?
	
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

let serviceParameters = UmbrellaPlaygroundServiceParameter<GameScore>()

let test = RequestController(serviceParameters: serviceParameters)
let gameScore = GameScore(json: [
	"score": 1337,
	"cheatMode": false,
	"playerName": "Sean Plott"
	])

let saveResponse: (response: GameScore) -> () = {(response: GameScore) -> () in
	let gameScore = response
}

let retreiveResponse: (response: [GameScore]) -> () = {(response: [GameScore]) -> () in
	let gameScores = response
}



test.save(gameScore, completion: saveResponse)

test.retrieve(retreiveResponse)

//Retreive single instance
let retreiveSingleInstanceResponse: (response: GameScore) -> () = {(response: GameScore) -> () in
	let gameScore = response
//	XCPlaygroundPage.currentPage.finishExecution()
}
test.retrieve("ta40DRgRAn", completion: retreiveSingleInstanceResponse)


//To let async code work
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
