import Quick
import Nimble

import Faro
@testable import Faro_Example

class OrderSpec: QuickSpec {

    override func spec() {
        describe("Order") {
            let expected = "path"
            let order = Order(path: expected)

            context("initialisation") {
                it("should have a path") {
                    expect(order.path).to(equal(expected))
                }

                it("should default to .GET") {
                    expect(order.method.rawValue).to(equal("GET"))
                }

                it("should configuration should make up request") {
                    let configuration = Faro.Configuration(baseURL: "http://someURL")

                    let order = Order(path: "path")

                    let url = order.urlForConfiguration(configuration)

                    expect(url!.absoluteString).to(equal("http://someURL/path"))
                }
            }
        }
    }

}
