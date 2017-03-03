//
//  FaroURLSessionDelegate.swift
//  Pods
//
//  Created by Stijn Willems on 03/03/2017.
//
//

import Foundation

class FaroURLSessionDelegate: NSObject, URLSessionDelegate {

	let challengeFunction: (_ challenge: URLAuthenticationChallenge, _ completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void

	init(_ challenge: @escaping (_ challenge: URLAuthenticationChallenge, _ completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) {
		self.challengeFunction = challenge
		super.init()
	}

	//swiftlint:disable line_length
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		self.challengeFunction(challenge, completionHandler)
	}

}
