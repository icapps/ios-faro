//
//  GameSoreController.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import AirRivet

/**
This class is used to bridge to swift generic classes to retreive and save GameScore objects.
*/
public class GameScoreController: NSObject {

	private let requestController = RequestController<GameScore>(serviceParameters: ParseExampleService <GameScore>())

	public func retrieve(completion:(response: [GameScore])->(), failure:((NSError)->())? = nil) {
		do {
			try requestController.retrieve({ (response) in
				completion(response: response)
				}, failure: { (requestError) in

			})
		}catch {
			
		}
	}
}