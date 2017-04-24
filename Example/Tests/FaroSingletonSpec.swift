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

class FaroSingletonSpec: QuickSpec {

    override func spec() {

        describe("FaroDeprecatedService mock switching") {
            context("should mock switch = true") {
                beforeEach {
                    FaroSingleton.sharedDeprecatedService = MockDeprecatedService()
                }

                it("Should use MockDeprecatedService") {
                    expect(FaroSingleton.shared is Faro.MockDeprecatedService) == true
                }
            }

            context("should mock switch = false") {
                beforeEach {
                    FaroSingleton.sharedDeprecatedService = nil
                }

                it("default to mocking when setup(with:) not called") {
                    expect(FaroSingleton.shared is Faro.MockDeprecatedService) == true
                }
            }
        }

    }
}
