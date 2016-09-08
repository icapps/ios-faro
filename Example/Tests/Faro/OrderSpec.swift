import Quick
import Nimble

import Faro
@testable import Faro_Example

class OrderSpec: QuickSpec {

    override func spec() {
        describe("Order .GET") {
            let expected = "path"
            let order = Order(path: expected)
            let configuration = Faro.Configuration(baseURL: "http://someURL")

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

        describe("Order Engagementrule") {
            it("should have rule .None or .All for a nodeKey") {
                let rules = [(nodeKey: "key 1", rule: EngagementRule.None), (nodeKey: "key 2", rule: EngagementRule.All)]
                let order = Order(path: "", rulesOfEngagement: rules)

                let rule1 = order.engagementRuleForNodeKey("key 1")
                let rule2 = order.engagementRuleForNodeKey("key 2")

                expect(rule1 == .None).to(beTrue())
                expect(rule2 == .All).to(beTrue())
            }
        }
    }

}
