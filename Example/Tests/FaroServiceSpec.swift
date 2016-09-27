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
        
        describe("FaroService") {
            context("should mock") {
                beforeEach {
                    MockSwitch.shouldMock = true
                }
                
                it("Should use MockService") {
                    expect(FaroService.shared is Faro.MockService) == true
                }
            }
        }
    }
}
