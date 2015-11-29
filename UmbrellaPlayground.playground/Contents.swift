//: # Swift generics used in service request
//: Here you can play around with the Umbrella framework to see if it works
/*: To start us Off we need to import some *frameworks*:
	1. UIKit for some CGFloats we use in a dispatch framework (not important)
	2. Umbrella -> this holds all the generic classes
	3. XCPPlaygound -> Needed because we do async calls
*/

import UIKit
import Umbrella
import XCPlayground

/*: 
## How did we compose the different objects?
	1. GameScore is a Type that conforms to protocol BaseModel. 
		The base model protocol defines two basic kind of requirements for our model object:
		1. Initialisation from json and some required properties
		2. Service related stuff: Error handling/ Service parameters
	2. 
*/

class GameScore: BaseModel {
	
	var score: Int?
	var cheatMode: Bool?
	var playerName: String?
	
	var objectId: String?
	var errorController: ErrorController
	
	required init(json: AnyObject) {
		errorController = PlayGroundErrorController()
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



class UnsavableGame: BaseModel {
	
	var objectId: String?
	var errorController: ErrorController
	
	required init(json: AnyObject) {
		errorController = PlayGroundErrorController()
		importFromJSON(json)
	}
	
	
	static func contextPath() -> String {
		return "Unsavable"
	}
	
	static func serviceParameters() -> ServiceParameter {
		return PlaygroundService<UnsavableGame>()
	}
	
	func body()-> NSDictionary? {
		return nil
	}
	func importFromJSON(json: AnyObject) {
		
	}
	
}
class PlayGroundErrorController: ErrorController {
	required init() {
		
	}
	func requestBodyError() throws {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
}

let serviceParameters = PlaygroundService <GameScore>()

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


//: #Save that succeeds

//do {
//	try test.save(gameScore, completion: saveResponse)
//}catch RequestError.InvalidBody {
//	print(RequestError.InvalidBody)
//	XCPlaygroundPage.currentPage.finishExecution()
//}

//Failed save
do {
	try test.save(UnsavableGame(json:[]), completion: saveResponse)
}catch RequestError.InvalidBody {
	print(RequestError.InvalidBody)
	XCPlaygroundPage.currentPage.finishExecution()
}

//
//test.retrieve(retreiveResponse)

//Retreive single instance
let retreiveSingleInstanceResponse: (response: GameScore) -> () = {(response: GameScore) -> () in
	let gameScore = response
//	XCPlaygroundPage.currentPage.finishExecution()
}
//test.retrieve("ta40DRgRAn", completion: retreiveSingleInstanceResponse)


//Try some Error
//test.retrieve("non existing object ID", completion: retreiveSingleInstanceResponse)


//To let async code work
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
