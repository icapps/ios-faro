import Foundation

import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class FaroSecureURLSessionSpec: QuickSpec {

	override func spec() {

		describe("Keep track of the retry count") {
            //swiftlint:disable trailint_whitespace
            beforeEach {
                let backendConfiguration = BackendConfiguration(baseURL: "http://www.stub.com")
                let urlConfiguration = URLSessionConfiguration.default
                //: Because of the following line the URLSession will behave stubbed for paths that we stub. More below
                urlConfiguration.protocolClasses = [StubbedURLProtocol.self]

                FaroURLSession.setup(backendConfiguration: backendConfiguration, urlSessionConfiguration: urlConfiguration)
            }

            fit("implement retry tests") {
                let call = Call(path: "tests")
                let mockData = """
                {
                    "uuid" = "test mock"
                }   
                """.data(using: .utf8)!

                call.stub(statusCode: 200, data: nil, waitingTime: 0.1)
                call.stub(statusCode: 200, data: mockData, waitingTime: 2)

                FaroURLSession.shared().enableRetry(with: { (_, response, _) -> Bool in
                    return (response as? HTTPURLResponse)?.statusCode == 401
                })

                // Second call should not call the completion block because
                let service = Service(call: call, autoStart: false)

                var task1: URLSessionTask!
                var task2: URLSessionTask!

                var task1Done = false
                var task2Done = false

                waitUntil(timeout: 2.0, action: { (done) in
                    task1 = service.perform(MockModel.self) { result in
                        expect {try result()}.to(throwError())
                        task1Done = true
                        done()
                    }
                    task1.resume()

                    return
                })

                task2 = service.perform(MockModel.self) { _ in
                    task2Done = true
                }

                task2.resume()

                expect(task1Done).toEventually(equal(true), timeout: 2.0)
                expect(task2Done).toNotEventually(equal(true), timeout:5.0)

            }
        }

	}

}
