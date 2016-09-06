import Quick
import Nimble

import Faro
@testable import Faro_Example

class OrderSpec: QuickSpec {

    override func spec() {
        describe("Order") {
            let expected = "path"
            let order = Order(path: expected)
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            context("initialisation . GET") {

                it("should have a path") {
                    expect(order.path).to(equal(expected))
                }

                it("should default to .GET") {
                    let request = order.objectRequestConfiguration(configuration)!
                    expect(request.HTTPMethod).to(equal("GET"))
                }

                it("should configuration should make up request") {

                    let request = order.objectRequestConfiguration(configuration)!
                    expect(request.URL!.absoluteString).to(equal("http://someURL/path"))
                }
            }
        }
    }

}
