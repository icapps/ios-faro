//
//  FaroURLSessionDelegate.swift
//  Pods
//
//  Created by Stijn Willems on 03/03/2017.
//
//

import Foundation

/// Use this to implement your own security
open class FaroURLSessionDelegate: NSObject, URLSessionDelegate {

	public let allowUntrustedCertificates: Bool

	public init(allowUntrustedCertificates: Bool) {
		self.allowUntrustedCertificates = allowUntrustedCertificates
		super.init()
	}

	//swiftlint:disable line_length
	/// Checks befare a tests is completed wether the Session may or may not handle the response from the server. 
	/// Tipically a secure sessions wants to override this function but we provide a default implementation.
	open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		// You can do all sorts of things here:
		// Certificate pinning
		// Allow untrusted certificates
		// ...
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
