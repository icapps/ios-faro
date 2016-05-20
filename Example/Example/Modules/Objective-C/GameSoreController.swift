//
//  GameSoreController.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation
import AirRivet

/**
This class is used to bridge to swift generic classes to fetch and save GameScore objects.
*/
class GameScoreController: NSObject {

    // MARK: - Variables
    
	let generalErrorDomain = "com.icapps.generalError"
	let generalErrorCode = 50000
	let gameScore : GameScore?
    
    // MARK: - Init

	override init() {
		self.gameScore = nil
        
		super.init()
	}
    
    // MARK: - Fetching
	
	func retrieve(completion:(response: [GameScore])->(), failure:((error: NSError)->())? = nil) {
		do {
			try Air.fetch(succeed: { (response: [GameScore]) in
					completion(response: response)
				}, fail: { (requestError) in
					if let failure = failure {
						self.transferResponseErrorToNSErrorForError(requestError, failure: failure)
					}
			})
		}catch {
			if let failure = failure {
				self.transferResponseErrorToNSErrorForError(error, failure: failure)
			}
		}
	}
    
    // MARK: - Error handling

	private func transferResponseErrorToNSErrorForError(error: ErrorType, failure:((NSError) ->())){
		//TODO: Split and unit test this better and complete
		guard let error = error as? RequestError else {
			failure(generalError())
			return
		}

		switch error {
		case .General :
			failure(generalError())
		default:
			failure(generalError())
		}
	}

	private func generalError() -> NSError {
		return NSError(domain: "\(generalErrorDomain)" , code: generalErrorCode, userInfo: ["message": "general error"])
	}
}