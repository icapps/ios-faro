
import Quick
import Nimble

import Faro
@testable import Faro_Example

class BarSpec: QuickSpec {
    override func spec() {
        describe("Bar") {
            context(".Model(model)") {
                var bar: Bar!
                var mockJSON: AnyObject!

                beforeEach({
                    mockJSON = ["key": "value"]
                    bar = Bar(service: MockService(mockJSON: mockJSON))

                })

                it("should have a configuration with the correct baseUrl") {
                    expect(bar.service.configuration.baseURL).to(equal("mockService"))
                }

                it("should return in sync with the mock model") {
                    let order = Order(path: "unitTest")
                    var isInSync = false

                    bar.serve(order) { (result: Result <MockModel>) in
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
