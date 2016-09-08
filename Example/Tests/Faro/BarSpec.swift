
import Quick
import Nimble

import Faro
@testable import Faro_Example

class BarSpec: QuickSpec {
    override func spec() {
        describe("Bar") {
            context("when Bar returns with Result.Model()") {
                var baseURL: String!
                var configuration: Faro.Configuration!
                var bar: Bar!
                var mockJSON: AnyObject!

                beforeEach({
                    mockJSON = ["key": "value"]
                    baseURL = "http://www.something.be"
                    configuration = Configuration(baseURL: baseURL)
                    bar = Bar(configuration: configuration)

                })

                it("should have a configuration with the correct baseUrl") {
                    expect(bar.configuration.baseURL).to(equal(baseURL))
                }

                it("should return in sync with the mock model") {
                    let order = Order(path: "unitTest")
                    var isInSync = false

                    bar.serve(order, service: MockService(mockJSON: mockJSON)) { (result: Result <MockModel>) in
                        isInSync = true
                        switch result {
                        case .Model(model: let model):
                            expect(model.value).to(equal("value"))
                        default:
                            XCTFail("You should succeed")
                        }
                    }

                    expect(isInSync).to(beTrue())
                }
            }
        }
    }
}
