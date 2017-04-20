//
//  FaroDeprecatedServiceSpec.swift
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

class FaroDeprecatedServiceSpec: QuickSpec {

    override func spec() {

        describe("FaroDeprecatedService mock switching") {
            context("should mock switch = true") {
                beforeEach {
                    FaroDeprecatedService.sharedDeprecatedService = MockDeprecatedService()
                }

                it("Should use MockDeprecatedService") {
                    expect(FaroDeprecatedService.shared is Faro.MockDeprecatedService) == true
                }
            }

            context("should mock switch = false") {
                beforeEach {
                    FaroDeprecatedService.sharedDeprecatedService = nil
                }

                it("default to mocking when setup(with:) not called") {
                    expect(FaroDeprecatedService.shared is Faro.MockDeprecatedService) == true
                }
            }
        }

    }
}
