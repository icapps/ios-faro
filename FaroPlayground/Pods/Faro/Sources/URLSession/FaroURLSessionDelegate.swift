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

// MARK: - Example code for Certificate pinning
//
//if ([ANVYeloBackend getEnvironment] != ANVYeloEnvironmentPrd || ![challenge.protectionSpace.host containsString:@"yeloplay.be"]) {
//	if (completionHandler) {
//		completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
//		return;
//	}
//	return;
//}
//
//if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//	SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
//	SecTrustResultType secureResult = kSecTrustResultInvalid;
//	OSStatus status = SecTrustEvaluate(serverTrust, &secureResult);
//
//	if (errSecSuccess == status) {
//		SecKeyRef serverKey = SecTrustCopyPublicKey(serverTrust);
//
//		NSString *certPath = [[NSBundle mainBundle] pathForResource:@"yeloplaybe" ofType:@"cer"];
//		NSData *certData = [NSData dataWithContentsOfFile:certPath];
//		SecCertificateRef localCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
//
//		SecKeyRef localKey = NULL;
//		SecTrustRef localTrust = NULL;
//		SecCertificateRef certRefs[1] = {localCertificate};
//		CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, (void *)certRefs, 1, NULL);
//		SecPolicyRef policy = SecPolicyCreateBasicX509();
//		OSStatus status = SecTrustCreateWithCertificates(certArray, policy, &localTrust);
//
//		if (status == errSecSuccess) {
//			localKey = SecTrustCopyPublicKey(localTrust);
//		}
//
//		if (serverKey != NULL && localKey != NULL && [(__bridge id)serverKey isEqual:(__bridge id)localKey]) {
//			CFRelease(policy);
//			CFRelease(serverKey);
//			CFRelease(localKey);
//			if (completionHandler) {
//				completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
//				return;
//			}
//		}
//	}
//}
//if (completionHandler) {
//	completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
//}
