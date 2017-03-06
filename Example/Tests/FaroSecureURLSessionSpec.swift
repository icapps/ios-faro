import Foundation

import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class RetryFaroSecureURLSession: FaroSecureURLSession, HTTPURLResponseRetryable {

	func shouldRetry(_ response: HTTPURLResponse) -> Bool {
		return true
	}

	func makeRequestValidforRetry(failedRequest: URLRequest,
	                              after httpResponse: HTTPURLResponse,
	                              retryCount: Int,
	                              requestForRetry: @escaping (URLRequest) -> Void,
	                              noRetryNeeded: @escaping (FaroError?) -> Void) {
		requestForRetry(failedRequest)
	}

}

enum RetryError: Error {
	case stop
}

class RetryStoppedFaroSecureURLSession: RetryFaroSecureURLSession {

	override func makeRequestValidforRetry(failedRequest: URLRequest,
	                                       after httpResponse: HTTPURLResponse,
	                                       retryCount: Int,
	                                       requestForRetry: @escaping (URLRequest) -> Void,
	                                       noRetryNeeded: @escaping (FaroError?) -> Void) {
		noRetryNeeded(nil)
	}

}

class FaroSecureURLSessionSpec: QuickSpec {

	override func spec() {

		describe("Keep track of the retry count") {

			var session: RetryFaroSecureURLSession!
			var testRequest: URLRequest!
			var httpResponse: HTTPURLResponse!

			beforeEach {
				session = RetryFaroSecureURLSession(urlSessionDelegate: FaroURLSessionDelegate(allowUntrustedCertificates: false))
				testRequest = URLRequest(url: URL(string: "http://www.google.com")!)
				httpResponse =  HTTPURLResponse(url: testRequest.url!, statusCode: 401, httpVersion:nil, headerFields: nil)!
			}

			fit("should retry and count") {

				expect(session.shouldRetry(httpResponse)) == true
				expect(session.retryCountTuples.map {$0.count}) == []

				session.handleRetry(data: nil, httpResponse: httpResponse, for: testRequest, completionHandler: {(_, _, _) in }, task: { (_) in
				}, noRetryNeeded: {_ in})

				expect(session.retryCountTuples.map {$0.count}) == [1]
			}

			context("has tried once") {
				beforeEach {
					session.handleRetry(data: nil, httpResponse: httpResponse, for: testRequest, completionHandler: {(_, _, _) in }, task: { (task) in
					}, noRetryNeeded: { (_) in
					})

					expect(session.retryCountTuples.map {$0.count}) == [1]
				}

				it("count should increase a second time") {
					session.handleRetry(data: nil, httpResponse: httpResponse, for: testRequest, completionHandler: {(_, _, _) in }, task: { (task) in
					}, noRetryNeeded: { (_) in
					})

					expect(session.retryCountTuples.map {$0.count}) == [2]
				}

				it("removes request from retryCount when finished") {
					session.handleEnding(for: testRequest)

					expect(session.retryCountTuples.map {$0.count}) == []
				}

				it("still contains other retry counts after one is stopped") {
					session.retryCountTuples.append((requestIdentifier: "169", count: 10))

					session.handleEnding(for: testRequest)

					expect(session.retryCountTuples.map {$0.requestIdentifier}) == ["169"]
				}

			}

		}

		describe("Stop retrying") {
			var session: RetryStoppedFaroSecureURLSession!
			var testRequest: URLRequest!
			var httpResponse: HTTPURLResponse!

			beforeEach {
				session = RetryStoppedFaroSecureURLSession(urlSessionDelegate: FaroURLSessionDelegate(allowUntrustedCertificates: false))
				testRequest = URLRequest(url: URL(string: "http://www.google.com")!)
				session.retryCountTuples.append((requestIdentifier: testRequest.requestIdentifier, count: 1))
				httpResponse =  HTTPURLResponse(url: testRequest.url!, statusCode: 401, httpVersion:nil, headerFields: nil)!
			}

			it("has request in retry") {
				expect(session.retryCountTuples.map {$0.requestIdentifier}) == [testRequest.requestIdentifier]
			}

			it("removes request when stopped") {
				session.handleEnding(for: testRequest)
				expect(session.retryCountTuples.map {$0.requestIdentifier}) == []
			}

			it("still contains other retry counts after one is stopped") {
				session.retryCountTuples.append((requestIdentifier: "169", count: 10))

				session.handleRetry(data: nil, httpResponse: httpResponse, for: testRequest, completionHandler: {(_, _, _) in }, task: { (task) in
				}, noRetryNeeded: { (_) in
				})

				expect(session.retryCountTuples.map {$0.requestIdentifier}) == ["169"]
			}

		}

	}

}
