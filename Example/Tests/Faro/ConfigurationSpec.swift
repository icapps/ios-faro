import Quick
import Nimble

import Faro

class ConfigurationSpec: QuickSpec {

    override func spec() {
        describe("Configuration") {

            context("initialisation") {
                it("should have a baseURL"){
                    let expected = "http://www.something.be"
                    let configuration = Configuration(baseURL: expected)

                    expect(configuration.baseURL).to(equal(expected))
                }
            }
        }
    }
    
}
