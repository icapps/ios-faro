import Foundation
import Quick
import Nimble

import Faro
@testable import Faro_Example

class ErrorSpec: QuickSpec {

    override func spec() {
        describe("ErrorSpec") {

            context("NSError") {
                it("should retrun Error for NSError") {
                    let nsError = NSError(domain: "MyDomain", code: 101, userInfo: ["info": "This is an nsError"])
                    let error = FaroError.nonFaroError(nsError)

                    expect(error).toNot(beNil())
                }
            }
        }
    }

}
