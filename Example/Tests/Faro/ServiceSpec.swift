import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {
    override func spec() {
        describe("Service") {
            context("MockService") {
                it("should return mockModel in sync"){
                    let expected = ["key" : "value"]
                    let service = MockService(mockJSON: expected)
                    let order = Order(path: "mock")
                    var isInSync = false

                    service.serve(order, result: { (result : Result <MockModel>) in
                        isInSync = true
                        switch result {
                        case .JSON(json: let json):
                            expect(json).to(beIdenticalTo(expected))
                        default:
                            XCTFail("You should succeed")
                        }
                    })

                    expect(isInSync).to(beTrue())
                }
            }
        }
    }  
}
