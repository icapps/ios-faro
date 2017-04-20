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

class FaroDeprecatedSingletonSpec: QuickSpec {

    override func spec() {

        describe("FaroDeprecatedService mock switching") {
            context("should mock switch = true") {
                beforeEach {
                    FaroDeprecatedSingleton.sharedDeprecatedService = MockDeprecatedService()
                }

                it("Should use MockDeprecatedService") {
                    expect(FaroDeprecatedSingleton.shared is Faro.MockDeprecatedService) == true
                }
            }

            context("should mock switch = false") {
                beforeEach {
                    FaroDeprecatedSingleton.sharedDeprecatedService = nil
                }

                it("default to mocking when setup(with:) not called") {
                    expect(FaroDeprecatedSingleton.shared is Faro.MockDeprecatedService) == true
                }
            }
        }

    }
}
