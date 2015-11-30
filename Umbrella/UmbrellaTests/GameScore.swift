//
//  File.swift
//  Umbrella
//
//  Created by Stijn Willems on 30/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation
import Umbrella

class GameScore: BaseModel {
	
	var score: Int?
	var cheatMode: Bool?
	var playerName: String?
	
	var objectId: String?
	var errorController: ErrorController
	
	required init(json: AnyObject) {
		errorController = ConcreteErrorController()
		importFromJSON(json)
	}
	
	static func getErrorController() -> ErrorController {
		return ConcreteErrorController()
	}
	
	//MARK: BaseModel Protocol Type
	static func contextPath() -> String {
		return "GameScore"
	}
	
	static func serviceParameters() -> ServiceParameters {
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
			if let objectId = json["objectId"] as? String {
				self.objectId = objectId
			}
			if let score = json["score"] as? Int {
				self.score = score
			}
			if let cheatMode = json["cheatMode"] as? Bool {
				self.cheatMode = cheatMode
			}
			
			if let playerName = json["playerName"] as? String {
				self.playerName = playerName
			}
		}
	}
}