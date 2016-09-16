import Quick
import Nimble

import Faro
@testable import Faro_Example

class CallSpec: QuickSpec {

    override func spec() {
        describe("Call .GET") {
            let expected = "path"
            let call = Call(path: expected)
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            it("should have a path") {
                expect(call.path).to(equal(expected))
            }

            it("should default to .GET") {
                let request = call.request(withConfiguration: configuration)!
                expect(request.httpMethod).to(equal("GET"))
            }

            it("should configuration should make up request") {
                let request = call.request(withConfiguration: configuration)!
                expect(request.url!.absoluteString).to(equal("http://someURL/path"))
            }

        }
    }

}
