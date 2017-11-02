//: [Previous](@previous)

//: ## 3. Handlers or Closure Parameters

/*:
 As you can see in the previous example pages data is returned to the service in an asynchronous way. This is done because the time before the service responds can be long. During this time you do not want the UI to be unresponsive. Thats why a background process waits for the response. When it arrives the background process needs a way to reach the UI. In Faro you have 2 options:

 1. A closure parameter. Every `perform` request has its own *block* of code that can be executed when the server responds.
 2. Service can hava handlers. These are stored blocks of code that will be triggered every time the server responds.

 In previous examples we have not yet discussed option 2. Lets dive in now!
*/
//: ### Service handlers



//: [Next](@next)
