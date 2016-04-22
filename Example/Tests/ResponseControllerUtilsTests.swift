//
//  ResponseControllerUtilsTests.swift
//  AirRivet
//
//  Created by Hans Van Herreweghe on 22/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import AirRivet

class DummyErrorController: ConcreteErrorController {
    override func responseDataEmptyError() throws {
        throw ResponseError.InvalidResponseData
    }
    
    override func responseInvalidError() throws {
        throw ResponseError.InvalidResponse
    }
    
    override func requestAuthenticationError() throws {
        throw RequestError.InvalidAuthentication
    }
}

class ResponseControllerUtilsTests: XCTestCase {
    
    lazy var errorController:ErrorController = ConcreteErrorController()
    
    func testNoResponseNoError() {
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:nil, error:nil), errorController: errorController)
            XCTFail("call should fail")
        } catch ResponseError.InvalidResponse {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testAuthenticationError() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 404, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:response, error:nil), errorController: errorController)
            XCTFail("call should fail")
        } catch RequestError.InvalidAuthentication {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
}
