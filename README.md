![](./Images/FaroShield.jpg)

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=57ea1d04856a610100f8208a&branch=develop&build=latest)](https://dashboard.buddybuild.com/apps/57ea1d04856a610100f8208a/build/latest)
 [![Version](https://img.shields.io/cocoapods/v/Faro.svg?style=flat)](http://cocoapods.org/pods/Faro) [![License](https://img.shields.io/cocoapods/l/Faro.svg?style=flat)](http://cocoapods.org/pods/Faro) [![Platform](https://img.shields.io/cocoapods/p/Faro.svg?style=flat)](http://cocoapods.org/pods/Faro)
[![Language Swift 3.0](https://img.shields.io/badge/Language-Swift%203.0-orange.svg?style=flat)](https://swift.org)

======

For a quick start follow the instructions below. For more in depth information on why and how we build Faro, the [wiki](https://github.com/icapps/ios-faro/wiki) page.

## VERSION 2.0

Version 2.0 is compatible with 1.0 but you will have to read the changle log and follow the migration hints.

## Concept
We build a service request by using a `Service` class as the point where you fire your `Call` and get a `Result`.

### Features

*Error handling*
* As of version 2.0 handling errors is done with throws. This can be confusing at first but it has the potential to reduce code.
* We focussed on making error descriptive and in `FaroError`
* All errors are printed by default

*Service*
* Service written to use Swift without using the Objective-C runtime
* Service cleanly encapsulates all the parameters to handle a network request in `Call`.
* Easily write a 'MockService' to load JSON from a local drive

*Automagically Parse*
* Use our JSONDeserialization and JSONSerialization operators to parse relations and properties

*Protocols*
* Because we use Protocols you can use any type including CoreData's `NSManagedObject` 💪🏼

*Mocking*
* Use `FaroSingleton` singleton if you want to switch between data from the server or a file.
* Handy for unit tests 💪🏼
* Handy if API is not yet available 🤓

## Define a Call

You can write your example service so that a call becomes a oneliner.
```Swift
let call = Call(path: "posts", method: HTTPMethod.GET, rootNode: "rootNode")
// the rootNode is used to query the json in the response in `rootNode(from json:)`
```
## Perform a Call

Take a look at the `ServiceSpec`, in short:

*Long version*
```swift
        let call = Call(path: "posts")
        let config = Configuration(baseURL: "http://jsonplaceholder.typicode.com"
        let service =  Service<Post>(call, deprecatedService: DeprecatedService(configuration: config)

        service.collection { [weak self] (resultFunction) in
      			DispatchQueue.main.async {
      				do {
      					let posts = try resultFunction() // Use the function to get the result or the error trown
      					self?.label.text = "Performed call for \(posts)"
      				} catch {
      					// printError(error) // errors are printed by default so you could leave this out
      				}
			  }
		}
```

*Short version*
```swift
        let call = Call(path: "posts")
        let config = Configuration(baseURL: "http://jsonplaceholder.typicode.com"
        let service =  Service<Post>(call, deprecatedService: DeprecatedService(configuration: config)

        service.collection {
      			DispatchQueue.main.async {
              let posts = try? $0() // Us anonymous closure arguments if you are comfortable with the syntax
              self?.label.text = "Performed call for posts"
			  }
		}
```

## JSONSerialize / JSONDeserialize

Deserialization and Serialization can happen automagically. For a more detailed example you can take a look at the ParseableSpec tests.

You can parse:

* primitive Types
* Dates
* enums
* Arrays/Sets of deserializable objects

### Deserializable

```swift
class Zoo: Deserializable {
    var uuid: String?
    var color: String?
    var animal: Animal?
    var date: Date?
    var animalArray: [Animal]?

    required init(from raw: [Sting: Any]) throws {
        self.uuid |< raw["uuid"]
        self.color |< json["color"]
        self.animal |< json["animal"]
        self.animalArray |< json["animalArray"]
        self.date |< (json["date"], "yyyy-MM-dd")
    }
}

```
### Serializable

```swift
extension Zoo: Serializable {

    var json: [String : Any?] {
        get {
            var json = [String: Any]()
            json["uuid"] <| self.uuid
            json["color"] <| self.color
            json["animal"] <| self.animal
            json["animalArray"] <| self.animalArray
            json["date"] <| self.date
            return json
        }
    }
}
```

### Type with required property

Because swift requires all properties to be set before we can call `map(from:)` on `self` you will have to do required properties manually.

````swift
class Gail: JSONDeserializable {
    var cellNumber: String
    var foodTicket: String?

    required init(from raw: [String :Any]) throws {
        cellNumber = try create("cellNumber", from: raw)
        self.foodTicket |< json["foodTicket"]
    }

}

```


## Requirements

- iOS 8 or higher
- Because we use generics you can only use this pod in Swift only files. You can mix and Match with Objective-C but not with generic classes.  Types [More info](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-ID53)

## Installation

Faro is available through [CocoaPods](http://cocoapods.org) and the [Swift Package Manager](https://swift.org/package-manager/).

To install it with CocoaPods, add the following line to your Podfile:

```ruby
pod "Faro"
```

## Contribution

> Don't think too hard, try hard!

More info on the [contribution guidelines](https://github.com/icapps/ios-faro/wiki/Contribution) wiki page.

### Coding Guidelines

We follow the [iCapps Coding guidelines](https://github.com/icapps/coding-guidelines/tree/master/iOS/Swift).

We use Swiftlint to keep everything neat.

## License

Faro is available under the MIT license. See the LICENSE file for more info.
