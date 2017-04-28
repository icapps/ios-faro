import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class DeprecatedServiceQueueSpec: QuickSpec {

    override func spec() {
        describe("DeprecatedServiceQueue") {

            var mockSession: MockAsyncSession!
            var service: DeprecatedServiceQueue!
            let call = Call(path: "mock")
            let config = Configuration(baseURL: "mockDeprecatedService")
            var isFinalCalled = false

            beforeEach {
                isFinalCalled = false
                mockSession = MockAsyncSession()
                mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)
            }

            context("not started") {

                var taskSucceed = false
                beforeEach {
                    isFinalCalled = false
                    taskSucceed = false
                    service = DeprecatedServiceQueue(configuration: config, faroSession: mockSession) { _ in
                        isFinalCalled = true
                        taskSucceed = true
                    }

                }

                it("add one") {
                    service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in
                        taskSucceed = true
                    }
                    expect(service.hasOustandingTasks) == true
                    expect(taskSucceed).toNotEventually(beTrue())
                }

                it("add multiple") {
                    let task1 = service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in
                        taskSucceed = true
                        }!
                    let task2 = service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in
                        taskSucceed = true
                        }!

                    let task3 = service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in
                        taskSucceed = true
                        }!

                    expect(service.hasOustandingTasks) == true
                    expect(taskSucceed).toNotEventually(beTrue())
                    expect(service.taskQueue).to(contain([task1, task2, task3]))
                    expect(isFinalCalled).toNotEventually(beTrue())
                }

                context("performWrite") {

                    it("should not be done without start") {
						_ = service.performWrite(call, autoStart: false) { _ in }
                        expect(service.hasOustandingTasks) == true
                    }
                }

            }

            context("started") {

                it("still start on autostart") {
                    service = DeprecatedServiceQueue(configuration: config, faroSession: mockSession) { _ in
                        print("final")
                    }
                    waitUntil { done in
                        service.perform(call, autoStart: true) { (_: DeprecatedResult<MockModel>) in
                            expect(service.hasOustandingTasks) == false
                            done()
                        }
                    }
                }

                context("multiple") {
                    var task1: URLSessionDataTask!
                    var task2: URLSessionDataTask!
                    var task3: URLSessionDataTask!

                    var failedTasks: Set<URLSessionTask>?

                    beforeEach {
                        isFinalCalled = false
                        service = DeprecatedServiceQueue(configuration: config, faroSession: mockSession) { failures in
                            isFinalCalled = true
                            failedTasks = failures
                        }

                        task1 = service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in }!
                        task2 = service.perform(call, autoStart: true) { (_: DeprecatedResult<MockModel>) in }!
                        task3 = service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in }!
                    }

                    it("not have failedTasks") {
                        expect(failedTasks).to(beNil())
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

                    context("final") {

                        it("all completed") {
                            service.resumeAll()
                            expect(isFinalCalled) == false
                            expect(isFinalCalled).toEventually(beTrue())
                        }

                        it("some completed") {
                            service.resume(task3)
                            expect(isFinalCalled) == false
                            expect(isFinalCalled).toNotEventually(beTrue())
                        }
                    }

                    context("some fail") {

                        var fail1: MockURLSessionTask!

                        beforeEach {
                            fail1 = service.perform(call, autoStart: false) { (_: DeprecatedResult<MockModel>) in } as? MockURLSessionTask
                            mockSession.tasksToFail = [fail1]
                        }

                        it("should queue the failed task") {
                            expect(service.taskQueue).to(contain(fail1))
                            expect(mockSession.tasksToFail).to(contain(fail1))
                        }

                        it("should report failure in final") {
                            service.resumeAll()
                            expect(failedTasks?.first).toEventually(equal(fail1))
                        }

                    }

                }
            }

        }
    }

}
