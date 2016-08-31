import Quick
import Nimble

import Faro
@testable import Faro_Example

class OrderSpec: QuickSpec {

    override func spec() {
        describe("Order") {

            context("initialisation") {
                it("should have a path"){
                    let expected = "path"
                    let order = Order(path: expected)

                    expect(order.path).to(equal(expected))
                }
            }
        }
    }
    
}
