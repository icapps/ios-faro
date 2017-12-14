import Faro
/*:
 # Faro

 It is recomended to first watch WWDC2017 session [Whats new in foundation](https://developer.apple.com/videos/play/wwdc2017/212/) and play with the [playground](https://developer.apple.com/documentation/foundation/archives_and_serialization/using_json_with_custom_types).

 We will show how to request data from a server.

 1. [Data received as an array](1.%20Data%20received%20as%20an%20array)
 2. [Data received as a Single object](2.%20Data%20received%20as%20a%20Single%20object)
 3. [Single Completion Handler or multiple Closure Parameters](3.%20Single%20Completion%20Handler%20or%20multiple%20Closure%20Parameters)
 4. [Handle different JSON formats](4.%20Handle%20different%20JSON%20formats)
 5. [Write to the Service](5.%20Write%20to%20the%20service)
 6. [Update existing objects](6.%20Update%20existing%20object)
 7. [Multi Part Post](7.%20Multi%20Part%20Post)
 8. [Retry](9.%20Retry)

 */
/*: # Setup your application
Faro operated with a singleton of a `URLSession`. This is because we support backgroun d requests and retries, see page 9.
 To setup Faro correctly in your Appdelegate you need to configure this singleton. In `applicationDidFinishLaunching:` you can put:
 */
 // I encourage to enable background, but you do not have to.
 FaroURLSession.setup(backendConfiguration: BackendConfiguration(baseURL:  "http://yourServer.com"),
 urlSessionConfiguration: URLSessionConfiguration.background(withIdentifier: "com.icapps.\(UUID().uuidString)"))
//: In the case of the playground there is a convenience function that we have to use on every page.
StubbedFaroURLSession.setup()
/*:
 ## WARNING
Sometimes playground does not compile the Stubbing.swift file in sources folder. This is because the import of Faro does not work. As a workaround comment `import Faro` build and uncomment and build.
## Why use Faro

1. You do not have to write parsing code thanks to Swift 4 Codable protocol
2. You get background request out of the box
3. If you have a service providers that requires you to reset a token after some time and you have a lot of paralell requests you will find page 9 a blizz!
*/
//: ---
//: [Next](@next)
