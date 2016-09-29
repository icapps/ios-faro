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
                    FaroService.sharedService = MockService()
                }
                
                it("Should use MockService") {
                    expect(FaroService.shared is Faro.MockService) == true
                }
            }

            context("should mock switch = false") {
                beforeEach {
                    FaroService.sharedService = nil
                }

                it("default to mocking when setup(with:) not called") {
                    expect(FaroService.shared is Faro.MockService) == true
                }
            }
        }

        
    }
}
