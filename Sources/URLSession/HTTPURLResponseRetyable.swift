//
//  ResponseRetryable.swift
//  Pods
//
//  Created by Stijn Willems on 06/03/2017.
//
//

import Foundation

public protocol HTTPURLResponseRetryable {

	func shouldRetry(_ response: HTTPURLResponse) -> Bool

	/// Make the request valid again based on the response
	/// If it is not possible you can throw any error and it will be printed.
	/// After throwing the original data, response, error will be send to the completion handler
	/// If not thrown a new URLSessionDataTask is made and given to the URLSession to be handled.
	/// - parameter request: the request to make valid again
	/// - parameter httpResponse: the received response
	/// - parameter retryCount: the amount of times we asked the implementer of HTTPURLResponseRetryable to retry the request. If this is to high throw any error to stop.
	func makeRequestValidforRetry(failedRequest: inout URLRequest, after httpResponse: HTTPURLResponse, retryCount: Int, requestForRetry: @escaping (inout URLRequest) -> Void, noRetryNeeded: @escaping (FaroError?) -> Void)

}
