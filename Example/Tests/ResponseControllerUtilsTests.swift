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
    
    override func requestGeneralError() throws {
        throw RequestError.General
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
    
    func testGeneralError() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 310, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:response, error:nil), errorController: errorController)
            XCTFail("call should fail")
        } catch RequestError.General {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testValidResponseNoData() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:response, error:nil), errorController: errorController)
            XCTFail("call should fail")
        } catch ResponseError.InvalidResponseData {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testValidResponse200WithData() {
        let url = NSURL(string: "https://some.url")
        
        //Some random data
        var random = NSInteger(arc4random_uniform(99) + 1)
        let data = NSData(bytes: &random, length: 3)
        
        let response = NSHTTPURLResponse(URL:url!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:data, urlResponse:response, error:nil), errorController: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
    
    func testValidResponse201WithData() {
        let url = NSURL(string: "https://some.url")
        
        //Some random data
        var random = NSInteger(arc4random_uniform(99) + 1)
        let data = NSData(bytes: &random, length: 3)
        
        let response = NSHTTPURLResponse(URL:url!, statusCode: 201, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:data, urlResponse:response, error:nil), errorController: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
}
