import Quick
import Nimble

import Faro

class ConfigurationSpec: QuickSpec {

    override func spec() {
        describe("Configuration") {
            let expected = "http://www.something.be"
            let configuration = Configuration(baseURL: expected)

            context("initialisation") {
                it("should have a baseURL") {
                    expect(configuration.baseURLString).to(equal(expected))
                }
            }
        }
    }

}
