//
//  ResponseUtilsTests.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import XCTest

@testable import AirRivet

// MARK: - Mocks

class DummyMitigator: MitigatorDefault {
    
	override func invalidResponseData(data: NSData?) throws {
		throw ResponseError.InvalidResponseData(data: data)
    }
    
    override func invalidAuthenticationError() throws {
        throw ResponseError.InvalidAuthentication
    }
    
    override func generalError() throws {
        throw RequestError.General
    }
    
}

// MARK: - Specs

//TODO: Refactor to nimble
class ResponseUtilsTests: XCTestCase {
    
    lazy var errorController = MitigatorNoPrinting()

    func testNoResponseNoError() {
        do {
            try ResponseUtils.checkStatusCodeAndData( mitigator: errorController)
        }  catch {
            XCTFail("We should not fail when an empty urlResponse is given")
        }
    }
    
    func testAuthenticationError() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 404, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseUtils.checkStatusCodeAndData(urlResponse:response, mitigator: errorController)
            XCTFail("call should fail")
        } catch ResponseError.InvalidAuthentication {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testGeneralError() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 310, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseUtils.checkStatusCodeAndData(urlResponse:response, mitigator: errorController)
            XCTFail("call should fail")
        } catch ResponseError.General(_) {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }
    
    func testValidResponseNoData() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseUtils.checkStatusCodeAndData(urlResponse:response, mitigator: errorController)
            XCTFail("call should fail")
        } catch ResponseError.InvalidResponseData {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testValidResponse200WithData() {
        let url = NSURL(string: "https://some.url")
        var random = NSInteger(arc4random_uniform(99) + 1)
        let data = NSData(bytes: &random, length: 3)
        
        let response = NSHTTPURLResponse(URL:url!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseUtils.checkStatusCodeAndData(data, urlResponse:response, mitigator: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
    
    func testValidResponse201WithData() {
        let url = NSURL(string: "https://some.url")
        var random = NSInteger(arc4random_uniform(99) + 1)
        let data = NSData(bytes: &random, length: 3)
        
        let response = NSHTTPURLResponse(URL:url!, statusCode: 201, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseUtils.checkStatusCodeAndData(data, urlResponse:response, mitigator: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
    
}
