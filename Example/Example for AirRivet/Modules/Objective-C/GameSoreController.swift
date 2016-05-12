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

    // MARK: - Variables
    
	public let generalErrorDomain = "com.icapps.generalError"
	public let generalErrorCode = 50000
	public let gameScore : GameScore?
    
    // MARK: - Init

	public override init() {
		self.gameScore = nil
        
		super.init()
	}
    
    // MARK: - Fetching
	
	public func retrieve(completion:(response: [GameScore])->(), failure:((error: NSError)->())? = nil) {
		do {
			try Air.retrieve(succeed: { (response: [GameScore]) in
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