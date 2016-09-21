
import Quick
import Nimble

import Faro
@testable import Faro_Example

class SerializeOpereratorsSpec: QuickSpec {

    override func spec() {
        describe("SerializeOpereratorsSpec") {

            it("should insert value") {
                var expectedString: String?
                let expected = "some string"

                expectedString <- expected

                expect(expectedString) == "bla"
            }
        }
    }
    
}

