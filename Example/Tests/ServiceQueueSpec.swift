
import Quick
import Nimble

@testable import Faro
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

                    var succeeded = false

                    beforeEach {
                        succeeded = false
                        service = ServiceQueue(configuration: config, faroSession: mockSession) {
                            succeeded = true
                        }

                    }

                    it("add one") {
                        service.perform(call, autoStart: false) { (result: Result<MockModel>) in
                            succeeded = true
                        }
                        expect(service.hasOustandingTasks) == true
                        expect(succeeded).toNotEventually(beTrue())
                    }

                    it("add multiple") {
                        let task1 = service.perform(call, autoStart: false) { (result: Result<MockModel>) in
                            succeeded = true
                        }!
                        let task2 = service.perform(call, autoStart: false) { (result: Result<MockModel>) in
                            succeeded = true
                        }!

                        let task3 = service.perform(call, autoStart: false) { (result: Result<MockModel>) in
                            succeeded = true
                        }!

                        expect(service.hasOustandingTasks) == true
                        expect(succeeded).toNotEventually(beTrue())
                        expect(service.taskQueue).to(contain([task1, task2, task3]))
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

                    context("multiple") {
                        var task1: URLSessionDataTask!
                        var task2: URLSessionDataTask!
                        var task3: URLSessionDataTask!

                        beforeEach {
                            service = ServiceQueue(configuration: config, faroSession: mockSession) {
                                print("final")
                            }
                            task1 = service.perform(call, autoStart: false) { (_: Result<MockModel>) in }!
                            task2 = service.perform(call, autoStart: true) { (_: Result<MockModel>) in }!
                            task3 = service.perform(call, autoStart: false) { (_: Result<MockModel>) in }!
                        }

                        it("autoStart one") {
                            expect(service.taskQueue).to(contain([task1, task2, task3]))
                            expect(service.taskQueue).toNotEventually(contain([task2]))
                            expect(service.taskQueue).toEventually(contain([task1, task3]))
                        }

                        it("one extra") {
                            service.resume(task3)
                            expect(service.taskQueue).to(contain([task1, task2, task3]))
                            expect(service.taskQueue).toNotEventually(contain([task2, task3]))
                            expect(service.taskQueue).toEventually(contain([task1]))
                        }

                        it("all") {
                            service.resumeAll()
                            expect(service.taskQueue).to(contain([task1, task2, task3]))
                            expect(service.taskQueue).toNotEventually(contain([task1, task3]))
                        }

                        context("invalidate") {

                            it("removeAll") {
                                expect(service.hasOustandingTasks) == true
                                service.invalidateAndCancel()
                                expect(service.hasOustandingTasks) == false
                            }

                        }
                    }

                }
            }
        }
    }
    
}
