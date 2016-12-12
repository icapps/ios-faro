# Faro
### Write service request from __Call__ to __Model__(s) of any Type.

---
# Inspired by

* https://github.com/postmates/PMHTTP
* http://szulctomasz.com/how-do-I-build-a-network-layer/
* https://swift.org

---
# Why

> Typicaly you ask yourself a lot of questions at the beginning of a project.

---

## Where to put the code that have knowledge about
* the backend url
* endpoints
* how to build a request
* preparing parameters for a request?

---
## What about security

* Where should I store authentication token?
* How to execute requests?
* When and where to execute requests?

---

## Handle edge cases
* Do I care about cancelling requests?
* Do I need to care about wrong backend responses? Some backend bugs?
* Do I need to use 3rd party frameworks? What frameworks should I use?
* Is there any core data stuff passing around?

---
### How to test the solution?

#### This is __too much__
##### Choose __3__ ...

---

1. Centralize knowledge about the requests
2. Handle edge cases, we tend to forget...
3. Make it testable.

> If we all use it, do we loose less time with new projects?

---
# What is a request

```swift
------------- = // Wire
```

```swift
[-
 -
 - ] = // Sreen
```

---
# What is a request

## __Serial__

````swift
------------- = // Wire
```

## _Deserialized_

```swift
[-
 -
 - ] = // Sreen
```

---

# Faro
## from __Top__  to __Bottom__

___

# __Top__
## _Deserialized_

```swift
[-
 -
 - ] = // Sreen
```
---
# __Top__
## _Deserialized_

```swift
class Zoo: Deserializable {
    var animal: Animal?

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any?] else {
            return nil
        }
        self.animal <-> json["animal"]
    }
}
```

---
# __Top__
## _Deserialized_
### Zoom into Deserialize __Operators__

```swift
self.animal <-> json["animal"]
```
---

# Why does this work?

```swift
public func <-> (lhs: inout Int?, rhs: Any?) {
    lhs = rhs as? Int
}

var x: Int!

x <-> json["any"] // returns Any?
```

---

# What about _multiple_ functions?

```swift
// A
public func <-> (lhs: inout Int?, rhs: Any?) {
    lhs = rhs as? Int
}
// B
public func <-> (lhs: inout String?, rhs: Any?) {
    lhs = rhs as? String
}

var x: Int!
var s: String!

x <-> json["any"] // returns Any? and goes to function A
s <-> json["any string"] // returns Any? and goes to function B
```
---

# In _Faro_ __Types__
## Are the _Holy grale_

---
# Moving __Down__
## _Serial_

````swift
------------- = // Wire
```

---

# Moving __Down__
## _Serial_
### The __Service__ binds the _'WIRE'_ to the _'SCREEN'_

```swift
open class Service {
    open let configuration: Configuration

    public init(configuration: Configuration, faroSession: FaroSessionable)
}
```

> Why is this so difficult?

---
# _Anything_ can happen,
## and __will__

````swift
--💀----💀-----💀-- = // Wire
```

### _You would still like to Deserialize_ after some __time__

---

## Configuration

```swift
/// Use for different configurations for the specific environment you want to use for *Bar.*
open class Configuration {
    open let baseURL: String

    /// For now we only support JSON. Can be Changed in the future
    open let adaptor: Adaptable
    open var url: URL?

    public init(baseURL: String, adaptor: Adaptable = JSONAdaptor())
}
```

The configuration can be changed to handle different kinds of serial data.

---

## FaroSessionable

### Protocol for `UrlSession`

### It's __Task__

* Should hold tasks that need to be __executed__
* handle & report about any __intermediate state__
* provide __data__, if available

---

# To the service it does not matter __where__ the data _comes from_
## _If_ we controll the session we can also controll the __data's origin__

= __Handy__ for tests.

---

> Should we change _production code_ for _testability_?

---
## More __Down__
### From Service to _Model_(s), __just 2 steps__

1. perform JSON
2. perform Deserialization

```swift
open func performJsonResult<M: Deserializable>

```
```swift
open func perform<M: Deserializable>
```

> `<M: Deserializable>` ?

---
> `<M: Deserializable>` ?

Can handle any __M__ that _conforms_ to __protocol `Deserializable`__

---
## Delivered to you via

```swift
public enum Result<M: Deserializable> {
    case model(M?)
}
```
---

## Delivered to you via

```swift
public enum Result<M: Deserializable> {
    case model(M?)
    case models([M]?)
}
```

---

```swift
public enum Result<M: Deserializable> {
    // MARK: - Success
    case model(M?)
    case models([M]?)
    /// Server returned with statuscode 200...201 but no response data. For Example Post
    case ok

    // MARK: - Intermediate results
    /// The server returned a valid JSON response.
    case json(Any)
    case data(Foundation.Data)

    // MARK: - Errors
    case failure(FaroError)
}
```
---
## Basic request
### Building blocks

```swift
let configuration = Configuration(baseURL: "http://jsonplaceholder.typicode.com")
let service = Service(configuration: configuration )
let call = Call(path: "posts")
```

---
## Basic request

```swift
service.perform(call) { (result: Result<Post>) in
    DispatchQueue.main.async {
        switch result {
        case .models(let models):
            print("🎉 \(models)")
        default:
            print("💣 fail")
        }
    }
})
```
---

# __Top__ & __Down__
### Are you still _here_?
> What was our _goal_?

1. Centralize knowledge about the requests

2. Handle edge cases, we tend to forget...
3. Make it testable.

---
1. Centralize knowledge about the requests 👌
  * `Call` & `Configuration` & `FaroSessionable`
2. Handle __edge cases__, we tend to forget... ⁉️
3. Make it testable. ⁉️

---
# Testing __First__

___

## Typical faro service request __SPEC__
### TOP __Down__

> You might want to work __Down__ up,
### see you later ... 🐊

---

```swift
     var service: Service!
     let call = Call(path: "mock")
     var mockSession: MockSession!

     beforeEach {
       mockSession = MockSession()
       let config = Configuration(baseURL: "mockService")
       service = Service(configuration: config, faroSession: mockSession)
       mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!,
                                  statusCode: 200, httpVersion:nil, headerFields: nil)
     }

     it("should return paging information") {
         var pagesInformation: PagingInformation!

         mockSession.data = "{\"pages\":10, \"currentPage\":25}".data(using: .utf8)

         service.perform(call, page: { (pageInfo) in
             pagesInformation = pageInfo
          }) { (result: Result<MockModel>) in
               // empty
         }

         expect(pagesInformation.pages) == 10
     }

```

---
# More test in __Example__

---
1. Centralize knowledge about the requests 👌
  * `Call` & `Configuration` & `FaroSessionable`
2. Handle __edge cases__, we tend to forget... ⁉️
3. Make it testable.
  * `MockSession` & `MockService`

> TODO split Test stuff off into seperate pod to make Faro testable

---
# Edge cases
### They are _a pain_ to write, let allone __Test__

> How does Faro help?

---
# Error printing and throwing

```swift
printFaroError(_ error: Error) {
    var faroError = error
    if !(error is FaroError) {
        faroError = FaroError.nonFaroError(error)
    }
    switch faroError as! FaroError {
    case .general:
        print("💣 General service error")
...

```
> Print functions implemented, but needs impovement

---

# Cancel and Queue
## Use `ServiceQueue`

> Why don't you try it...

---
1. Centralize knowledge about the requests 👌
  * `Call` & `Configuration` & `FaroSessionable`
2. Handle __edge cases__, we tend to forget...
  * `printFaroError` & `ServiceQueue`
3. Make it testable.
  * `MockSession` & `MockService`

---
# Q?
---
# Syntax _sugar_

---

```swift
class Post: Deserializable {
    let uuid: Int
    var title: String?

    enum ServiceMap: String {
        case id, title
    }

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any] else {
            return nil
        }
        do {
            self.uuid = try parse(Post.ServiceMap.id.rawValue, from: json)
        } catch {
            printError("Error parsing Post with \(error).")
            return nil
        }

        // Not required variables

        title <-> json[.title]
    }

}

```

---

```swift
extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

    subscript (map: Post.ServiceMap) -> Value? {
        get {
            guard let key = map.rawValue as? Key else {
                return nil
            }

            let dict = self[key] as Value?
            return dict

        } set (newValue) {
            guard let newValue = newValue, let key = map.rawValue as? Key  else {
                return
            }

            self[key] = newValue
        }
    }

}
```

> Use it at your own _Risk_ ...
