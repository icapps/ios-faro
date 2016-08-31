import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {

    override func spec() {
        describe("Service") {

            context("unit testing") {
                it("should return in sync"){
                    
                    let service = UnitTestService<MockModel>()
                    let order = Order(path: "mock")
                    var delivery : Delivery <MockModel>
                    service.serve(order, delivery: { () -> delivery in

                    })
                }
            }
        }
    }
    
}
