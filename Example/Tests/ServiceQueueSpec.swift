
import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceQueueSpec: QuickSpec {

    override func spec() {
        describe("ServiceQueueSpec") {

            context("Test the background queue behaviour") {

                var mockSession: MockSession!
                var service: ServiceQueue!
                let call = Call(path: "mock")

                beforeEach {
                    mockSession = MockSession()
                    service = ServiceQueue(configuration: Configuration(baseURL: "mockService"), session: mockSession)
                    mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)
                }

                context("not started") {

                    it("add taks to queue") {
                        var succeeded = false
                        service.perform(call, autoStart: false) { (result: Result<MockModel>) in
                            succeeded = true
                        }

                        expect(succeeded) == false
                    }
                }

                context("started") {

                }
            }
        }
    }
    
}
