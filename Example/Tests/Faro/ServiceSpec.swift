import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {
    override func spec() {
        describe("Service") {
            context("unit testing") {
                it("should return mockModel in sync"){
                    let expected = ["key" : "value"]
                    let service = UnitTestService(mockJSON: expected)
                    let order = Order(path: "mock")
                    var isInSync = false

                    service.serve(order, result: { (result) in
                        isInSync = true
                        switch result {
                        case .Success(let json):
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
