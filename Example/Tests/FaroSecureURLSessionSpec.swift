import Foundation

import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class RetryFaroSecureURLSession: FaroSecureURLSession, HTTPURLResponseRetryable {

	func shouldRetry(_ response: HTTPURLResponse) -> Bool {
		return true
	}

	func makeRequestValidforRetry(_ request: inout URLRequest, after httpResponse: HTTPURLResponse, retryCount: Int) throws {
	}

}

enum RetryError: Error {
	case stop
}

class RetryStoppedFaroSecureURLSession: RetryFaroSecureURLSession {

	override func makeRequestValidforRetry(_ request: inout URLRequest, after httpResponse: HTTPURLResponse, retryCount: Int) throws {
		throw RetryError.stop
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

			it("should retry and count") {

				expect(session.shouldRetry(httpResponse)) == true
				expect(session.retryCountTuples.map {$0.count}) == []

				var variableRequest = testRequest

				try? session.makeRequestValidforRetry(&variableRequest!, after: httpResponse, retryCount: session.retryCount(for: testRequest))

				expect(session.retryCountTuples.map {$0.count}) == [1]
			}

			context("has tried once") {
				beforeEach {
					let _ = session.handleRetry(data:nil, httpResponse: httpResponse, for: testRequest, completionHandler: {(_, _, _) in })

					expect(session.retryCountTuples.map {$0.count}) == [1]
				}

				it("count should increase a second time") {
					let _ = session.handleRetry(data:nil, httpResponse: httpResponse, for: testRequest, completionHandler: {(_, _, _) in })

					expect(session.retryCountTuples.map {$0.count}) == [2]
				}

				it("removes request from retryCount when finished") {
					session.handleEnding(for: testRequest)

					expect(session.retryCountTuples.map {$0.count}) == []
				}

				it("still contains other retry counts after one is stopped") {
					session.retryCountTuples.append((hashValue: 169, count: 10))

					session.handleEnding(for: testRequest)

					expect(session.retryCountTuples.map {$0.hashValue}) == [169]
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
				session.retryCountTuples.append((hashValue: testRequest.hashValue, count: 1))
				httpResponse =  HTTPURLResponse(url: testRequest.url!, statusCode: 401, httpVersion:nil, headerFields: nil)!
			}

			it("has request in retry") {
				expect(session.retryCountTuples.map {$0.hashValue}) == [testRequest.hashValue]
			}

			it("removes request when stopped") {
				session.handleEnding(for: testRequest)
				expect(session.retryCountTuples.map {$0.hashValue}) == []
			}

			it("still contains other retry counts after one is stopped") {
				session.retryCountTuples.append((hashValue: 169, count: 10))

				let _ = session.handleRetry(data: nil, httpResponse: httpResponse, for: testRequest, completionHandler: { (_, _, _) in})

				expect(session.retryCountTuples.map {$0.hashValue}) == [169]
			}

		}

	}

}
