//
//  FaroURLSessionDelegate.swift
//  Pods
//
//  Created by Stijn Willems on 03/03/2017.
//
//

import Foundation

open class FaroURLSessionDelegate: NSObject, URLSessionDelegate {

	public let allowUntrustedCertificates: Bool

	public init(allowUntrustedCertificates: Bool) {
		self.allowUntrustedCertificates = allowUntrustedCertificates
		super.init()
	}

	//swiftlint:disable line_length
	open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		if allowUntrustedCertificates {
			if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
				guard let trust  =  challenge.protectionSpace.serverTrust else {
					return
				}
				completionHandler(.useCredential, URLCredential(trust:trust))
			}
		}
	}

}
