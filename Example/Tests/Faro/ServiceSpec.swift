import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {

    override func spec() {

        describe("Service") {

            context("unit testing") {
                it("should return mockModel in sync"){

                    let mockModel = MockModel()
                    let service = UnitTestService<MockModel>(mockModel: mockModel)
                    let order = Order(path: "mock")

                    var isInSync = false

                    service.serve(order, delivery: { (delivery: Delivery <MockModel>) in
                        isInSync = true
                        switch delivery {
                        case .Success(let model):
                            expect(model).to(beIdenticalTo(mockModel))
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
