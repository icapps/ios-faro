//
//  ConcreteErrorControllerTests.swift
//  AirRivet
//
//  Created by Hans Van Herreweghe on 21/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import AirRivet

class ConcreteErrorControllerTests: XCTestCase {
    lazy var errorController = ConcreteErrorController()
    
    func testRequestBodyError() {
        do {
            try errorController.requestBodyError()
            XCTFail("method should throw error")
        } catch RequestError.InvalidBody {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testRequestAuthenticationError() {
        do {
            try errorController.requestAuthenticationError()
            XCTFail("method should throw error")
        } catch RequestError.InvalidAuthentication {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testRequestGeneralError() {
        do {
            try errorController.requestGeneralError()
            XCTFail("method should throw error")
        } catch RequestError.General {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
    func testRequestResponseDataEmpty() {
        do {
            try errorController.requestResponseDataEmpty()
            XCTFail("method should throw error")
        } catch RequestError.InvalidResponseData {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error type")
        }
    }
    
//    func testRequestResponseError() {
//        let error = NSError(domain: "com.icapps.test", code: 123, userInfo: [NSLocalizedDescriptionKey:"some error"])
//        do {
//            try errorController.requestResponseError(error)
//            XCTFail("method should throw error")
//        } catch RequestError.ResponseError(error) {
//            XCTAssertTrue(true)
//        } catch {
//            XCTFail("wrong error type")
//        }
//    }

        func testRequestResponseError() {
            let expectedError = NSError(domain: "com.icapps.test", code: 123, userInfo: [NSLocalizedDescriptionKey:"some error"])
            XCTAssertThrowsError(try errorController.requestResponseError(expectedError), "method should trow correct error") { error in
                guard let thrownError = error as? RequestError else {
                    XCTFail("wrong error type")
                    return
                }
                switch thrownError {
                case .ResponseError(let responseError):
                    XCTAssertEqual(responseError, expectedError)
                default:
                    XCTFail("wrong error type")
                }
            }
        }

}
