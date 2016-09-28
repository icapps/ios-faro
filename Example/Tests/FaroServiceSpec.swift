//
//  FaroServiceSpec.swift
//  Faro
//
//  Created by Ben Algoet on 27/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Faro

@testable import Faro_Example

class FaroServiceSpec: QuickSpec {
    
    override func spec() {
        
        describe("FaroService mock switching") {
            context("should mock switch = true") {
                beforeEach {
                    MockSwitch.shouldMock = true
                }
                
                it("Should use MockService") {
                    expect(FaroService.shared is Faro.MockService) == true
                }
            }

            context("should mock switch = false") {
                beforeEach {
                    MockSwitch.shouldMock = false
                }

                it("default to mocking when setup(with:) not called") {
                    expect(FaroService.shared is Faro.MockService) == true
                }
            }
        }

        describe("FaroServie mock data") {
            context("dictionary set") {
                var mockService: MockService!

                beforeEach {
                    MockSwitch.shouldMock = true
                    mockService = FaroService.shared as! MockService
                }

                it("should return dictionary after perform") {
                    let uuid = "dictionary for testing"
                    mockService.mockDictionary = ["uuid": uuid]

                    mockService.perform(Call(path: "unit tests")) { (result: Result<MockModel>) in
                        switch result {
                        case .model( let model):
                            expect(model!.uuid) == uuid
                        default:
                            XCTFail("should provide a model")
                        }
                    }
                }
            }

        }
    }
}
