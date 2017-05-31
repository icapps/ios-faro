//
//  ResponseUtilsTests.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import XCTest

@testable import AirRivet
@testable import AirRivet_Example

// MARK: - Mocks

class DummyMitigator: MitigatorDefault {
    
	override func invalidResponseData(_ data: Data?) throws {
		throw ResponseError.invalidResponseData(data: data)
    }
    
    override func invalidAuthenticationError() throws {
        throw ResponseError.invalidAuthentication
    }
    
    override func generalError() throws {
        throw RequestError.general
    }
    
}

// MARK: - Specs

//TODO: Refactor to nimble
class ResponseUtilsTests: XCTestCase {
    
    lazy var errorController = MitigatorNoPrinting()

    func testNoResponseNoError() {
        do {
            _ = try ResponseUtils.checkStatusCodeAndData( mitigator: errorController)
        }  catch {
            XCTFail("We should not fail when an empty urlResponse is given")
        }
    }
    
    func testAuthenticationError() {
        let url = URL(string: "https://some.url")
        let response = HTTPURLResponse(url:url!, statusCode: 404, httpVersion: nil, headerFields: nil)
        do {
            _ = try ResponseUtils.checkStatusCodeAndData(urlResponse:response, mitigator: errorController)
            XCTFail("call should fail")
        } catch ResponseError.invalidAuthentication {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testGeneralError() {
        let url = URL(string: "https://some.url")
        let response = HTTPURLResponse(url:url!, statusCode: 310, httpVersion: nil, headerFields: nil)
        do {
            _ = try ResponseUtils.checkStatusCodeAndData(urlResponse:response, mitigator: errorController)
            XCTFail("call should fail")
        } catch ResponseError.general(_) {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }
    
    func testValidResponseNoData() {
        let url = URL(string: "https://some.url")
        let response = HTTPURLResponse(url:url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            _ = try ResponseUtils.checkStatusCodeAndData(urlResponse:response, mitigator: errorController)
            XCTFail("call should fail")
        } catch ResponseError.invalidResponseData {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testValidResponse200WithData() {
        let url = URL(string: "https://some.url")
		let data = "dfa".data(using: .utf8)

        let response = HTTPURLResponse(url:url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            _ = try ResponseUtils.checkStatusCodeAndData(data, urlResponse:response, mitigator: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
    
    func testValidResponse201WithData() {
        let url = URL(string: "https://some.url")
		let data = "dfa".data(using: .utf8)

        let response = HTTPURLResponse(url:url!, statusCode: 201, httpVersion: nil, headerFields: nil)
        do {
            _ = try ResponseUtils.checkStatusCodeAndData(data, urlResponse:response, mitigator: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
    
}
