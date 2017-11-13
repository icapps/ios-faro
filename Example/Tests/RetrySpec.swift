import Foundation

import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class FaroSecureURLSessionSpec: QuickSpec {

	override func spec() {

		describe("Retry") {
            let call = Call(path: "tests")
            let mockData1 = """
                {
                    "uuid": "test mock"
                }
                """.data(using: .utf8)!
            let mockData2 = """
                {
                    "uuid": "test mock 2"
                }
                """.data(using: .utf8)!

            beforeEach {
                let backendConfiguration = BackendConfiguration(baseURL: "http://www.stub.com")
                let urlConfiguration = URLSessionConfiguration.default
                //: Because of the following line the URLSession will behave stubbed for paths that we stub. More below
                urlConfiguration.protocolClasses = [StubbedURLProtocol.self]

                FaroURLSession.setup(backendConfiguration: backendConfiguration, urlSessionConfiguration: urlConfiguration)
            }

            it("on 200 slow and fast task both succeed") {

                call.stub(statusCode: 200, data: mockData1, waitingTime: 0.1)
                call.stub(statusCode: 200, data: mockData2, waitingTime: 2.0)

                // Second call should not call the completion block because
                let service = Service(call: call, autoStart: false)

                var task1: URLSessionTask!
                var task2: URLSessionTask!

                var task1Done = false
                var task2Done = false

                task1 = service.perform(MockModel.self) { _ in
                    task1Done = true
                }
                task2 = service.perform(MockModel.self) { _ in
                    task2Done = true
                }

                task1.resume()
                task2.resume()

                expect(task1Done && task2Done).toEventually(equal(true), timeout: 5.0)

            }

            it("slow call should not succeed on 401") {
                FaroURLSession.shared().enableRetry(with: { (_, _, response, _) -> Bool in
                    return (response as? HTTPURLResponse)?.statusCode == 401
                }, fixCancelledRequest: {
                    return $0
                }, performRetry: {(done)in
                    done {
                        // throw errors inside this
                        // in this test everyting succeeds
                    }
                })

                call.stub(statusCode: 401, data: mockData1, waitingTime: 0.1)
                call.stub(statusCode: 200, data: mockData2, waitingTime: 2.0)

                // Second call should not call the completion block because
                let service = Service(call: call, autoStart: false)
                var task1: URLSessionTask!
                var task2: URLSessionTask!

                var task1Done = false
                var task2Done = false

                task1 = service.perform(MockModel.self) { _ in
                    task1Done = true
                }
                task2 = service.perform(MockModel.self) { _ in
                    task2Done = true
                }

                task1.resume()
                task2.resume()

                expect(task1Done).toEventually(equal(false))
                expect(task2Done).toNotEventually(equal(true))
            }
        }

	}

}
