Faro
[![CI Status](http://img.shields.io/travis/icapps/ios-faro.svg?style=flat)](https://travis-ci.org/icapps/ios-faro) [![Version](https://img.shields.io/cocoapods/v/Faro.svg?style=flat)](http://cocoapods.org/pods/Faro) [![License](https://img.shields.io/cocoapods/l/Faro.svg?style=flat)](http://cocoapods.org/pods/Faro) [![Platform](https://img.shields.io/cocoapods/p/Faro.svg?style=flat)](http://cocoapods.org/pods/Faro)
======

For a quick start follow the instructions below. For more in depth information on why and how we build Faro, the [wiki](https://github.com/icapps/ios-faro/wiki) page.

## Concept
We build a service request by using a `Service` class as the point where you fire your `Call` and get a `Result`.

### Features

*Service*
* Service written to use Swift without using the Objective-C runtime
* Service cleanly encapsulates all the parameters to handle a network request in `Call`.
* Easily write a 'MockService' to load JSON from a local drive

*Automagically Parse*
* Automatic Serialization and Mapping thanks to the use off the Swift 'Mirror' class.
* Uses Protocol extensions to minimize the work needed at your end 😎
* Because we use Protocols you can use any type including CoreData's `NSManagedObject` 💪🏼

## Define a Call

You can write your example service so that a call becomes a oneliner.
```Swift
let call = Call(path: "posts", method: HTTPMethod.GET, rootNode: "rootNode")
// the rootNode is used to query the json in the response in `rootNode(from json:)`
```
## Perform a Call

Take a look at the `ServiceSpec`, in short:
```swift
        let service = Service(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com")
        let call = Call(path: "posts")

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
## Serialize / Deserialize

Deserialization and Serialization can happen automagically. For a more detailed example you can take a look at the ParseableSpec tests.

### Type without relations

```swift
class Zoo: Deserializable {
    var uuid: String?
    var color: String?

    required init?(from raw: Any) {
        map(from: raw)
    }

    var mappers: [String : ((Any?)->())] {
        return ["uuid" : {self.uuid <-> $0 },
                "color" : {self.color <-> $0 },
                ]
    }

}

```

### Type with relations
```swift
class Zoo: Deserializable {
    var uuid: String?
    var color: String?
    var animal: Animal?
    var animalArray: [Animal]?

    required init?(from raw: Any) {
        map(from: raw)
    }

    var mappers: [String : ((Any?)->())] {
        return ["uuid" : {self.uuid <-> $0 },
                "color" : {self.color <-> $0 },
                "animal": {self.animal <-> $0},
                "animalArray": {self.animalArray <-> $0}
                ]
    }

}

```

### Type with required property

Because swift requires all properties to be set before we can call `map(from:)` on `self` you will have to do required properties manually.

````swift
class Gail: Deserializable {
    var cellNumber: String
    var foodTicket: String?

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }

        do {
            cellNumber = try parse("cellNumber", from: json)
        } catch {
            return nil
        }
        map(from: raw)
    }

    var mappers: [String : ((Any?) -> ())] {
        get {
            return ["foodTicket": {self.foodTicket <-> $0}]
        }
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
