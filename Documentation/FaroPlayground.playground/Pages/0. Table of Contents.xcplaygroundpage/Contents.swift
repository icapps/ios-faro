/*:
 # Faro

 It is recomended to first watch WWDC2017 session [Whats new in foundation](https://developer.apple.com/videos/play/wwdc2017/212/) and play with the [playground](https://developer.apple.com/documentation/foundation/archives_and_serialization/using_json_with_custom_types).

 We will show how to fetch data from a server.

 - [Fetch Data from Arrays](1.%20Fetch%20Data%20from%20Array)
 - [Fetch Data from Single object](2.%20Fetch%20Data%20from%20Single%20object)
 - [Single Complete Handler or multiple Closure Parameters](3.%20Single%20Complete%20Handler%20or%20multiple%20Closure%20Parameters)
 - [Handle different JSON formats](4.%20Handle%20different%20JSON%20formats)
 - [Write to the Service](5.%20Write%20to%20the%20service)
 - [Update existing objects](6.%20Update%20existing%20object)
 - [Multi Part Post](7.%20Multi%20Part%20Post)
 - [Retry](9.%20Retry)

 ## WARNING

 Sometimes playground does not compile the Stubbing.swift file in sources folder. This is because the import of Faro does not work. As a workaround comment `import Faro` build and uncomment and build.

 ## Why use Faro

 1. You do not have to write parsing code thanks to Swift 4 Codable protocol
 2. You get background request out of the box
 3. If you have a service providers that requires you to reset a token after some time and you have a lot of paralell requests you will find page 9 a blizz!

 ****
 */
//: [Next](@next)
