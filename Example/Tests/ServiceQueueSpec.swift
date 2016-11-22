
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
                let config = Configuration(baseURL: "mockService")

                beforeEach {
                    mockSession = MockAsyncSession()
                    mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)
                }

                context("not started") {

                    it("add taks to queue") {
                        var succeeded = false
                        service = ServiceQueue(configuration: config, faroSession: mockSession) {
                            succeeded = true
                        }

                        service.perform(call, autoStart: false) { (result: Result<MockModel>) in
                            succeeded = true
                        }
                        expect(service.hasOustandingTasks) == true
                        expect(succeeded).toNotEventually(beTrue())
                    }
                }

                context("started") {

                    it("still start on autostart") {
                        service = ServiceQueue(configuration: config, faroSession: mockSession) {
                            print("final")
                        }
                        waitUntil { done in
                            service.perform(call, autoStart: true) { (result: Result<MockModel>) in
                                expect(service.hasOustandingTasks) == false
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
    
}
