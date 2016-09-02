import Quick
import Nimble

import Faro

class ConfigurationSpec: QuickSpec {
    override func spec() {
        describe("Configuration") {
            let expected = "http://www.something.be"
            let configuration = Configuration(baseURL: expected)

            context("initialisation") {
                it("should have a baseURL"){
                    expect(configuration.baseURL).to(equal(expected))
                }

                it("should have a valid NSURL") {
                    expect(configuration.url).toNot(beNil())
                    expect(configuration.url?.absoluteString).to(equal(expected))
                }
            }
        }
    }    
}
