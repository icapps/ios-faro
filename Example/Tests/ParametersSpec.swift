import Quick
import Nimble

import Faro
@testable import Faro_Example

class ParametersSped: QuickSpec {

    override func spec() {
        describe("Parameters") {

            context("fail for specific types") {
                it("not accept non string url components") {
                    let parameters = Parameters(type: .urlComponents, parameters: ["int": 0])

                    expect(parameters).to(beNil())
                }
            }
        }
    }

}
