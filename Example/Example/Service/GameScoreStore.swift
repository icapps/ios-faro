//
//  GameScoreStore.swift
//  AirRivet
//
//  Created by Stijn Willems on 01/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import AirRivet

/**
Example of `GameScore` that can be used with a Transformer that stores json in a file in the documents folder

After using this class:

1. Go to application bundle
2. Open documents folder
3. Look at the JSON file inside
*/

class GameScoreStore: GameScore {
	override static func transform() -> TransformJSON {
		return TransformAndStore<GameScore>()
	}
}