import XCTest
@testable import AirRivet

class DummyMitigator: DefaultMitigator {
    override func responseDataEmptyError() throws {
        throw ResponseError.InvalidResponseData
    }
    
    override func responseInvalidError() throws {
        throw ResponseError.InvalidResponse
    }
    
    override func requestAuthenticationError() throws {
        throw ResponseError.InvalidAuthentication
    }
    
    override func requestGeneralError() throws {
        throw RequestError.General
    }
}

//TODO refactor to nimble
class ResponseControllerUtilsTests: XCTestCase {
    
    lazy var errorController:Mitigator = DefaultMitigator()

    func testNoResponseNoError() {
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:nil), errorController: errorController)
        }  catch {
            XCTFail("We should not fail when an empty urlResponse is given")
        }
    }
    
    func testAuthenticationError() {
        let url = NSURL(string: "https://some.url")
        let response = NSHTTPURLResponse(URL:url!, statusCode: 404, HTTPVersion: nil, headerFields: nil)
        do {
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:response), errorController: errorController)
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
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:response), errorController: errorController)
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
            try ResponseControllerUtils.checkStatusCodeAndData((data:nil, urlResponse:response), errorController: errorController)
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
            try ResponseControllerUtils.checkStatusCodeAndData((data:data, urlResponse:response), errorController: errorController)
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
            try ResponseControllerUtils.checkStatusCodeAndData((data:data, urlResponse:response), errorController: errorController)
            XCTAssertTrue(true)
        } catch {
            XCTFail("call should not fail")
        }
    }
}
