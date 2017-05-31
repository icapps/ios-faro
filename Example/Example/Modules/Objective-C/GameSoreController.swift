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
	let gameScore: GameScore?

    // MARK: - Init

	override init() {
		self.gameScore = nil

		super.init()
	}

    // MARK: - Fetching

	func retrieve(_ completion:@escaping (_ response: [GameScore])->Void, failure:((_ error: Error)->Void)? = nil) {
		do {
			try Air.fetch(succeed: { (response: [GameScore]) in
					completion(response)
				}, fail: { (requestError) in
					if let failure = failure {
						self.transferResponseErrorToNSErrorForError(requestError, failure: failure)
					}
			})
		} catch {
			if let failure = failure {
				self.transferResponseErrorToNSErrorForError(error, failure: failure)
			}
		}
	}

    // MARK: - Error handling

	fileprivate func transferResponseErrorToNSErrorForError(_ error: Error, failure: ((Error) ->Void)) {
		//TODO: Split and unit test this better and complete
		guard let error = error as? RequestError else {
			failure(generalError())
			return
		}

		switch error {
		case .general :
			failure(generalError())
		default:
			failure(generalError())
		}
	}

	fileprivate func generalError() -> Error {
		return RequestError.general
	}
}
