AirRivet [![CI Status](http://img.shields.io/travis/icapps/ios-air-rivet.svg?style=flat)](https://travis-ci.org/icapps/ios-air-rivet) [![Version](https://img.shields.io/cocoapods/v/AirRivet.svg?style=flat)](http://cocoapods.org/pods/AirRivet) [![License](https://img.shields.io/cocoapods/l/AirRivet.svg?style=flat)](http://cocoapods.org/pods/AirRivet) [![Platform](https://img.shields.io/cocoapods/p/AirRivet.svg?style=flat)](http://cocoapods.org/pods/AirRivet)
======

For a quick start follow the instructions below. For more in depth information on why and how we build AirRivet, you are more then welcome on the [wiki](https://github.com/icapps/ios-air-rivet/wiki) page.

## Concept

__AirRivet__ is a service layer build in Swift using generics.

The idea is that you have `Air` which is a class that performs the request for an `Environment`. To do this it needs a Type called `Rivet` that can be handled over the `Air` 🤔. So how do we make this `Rivet` Type?

`AnyThing` can be a `Rivet` if they are `Rivetable`. `Rivetable` is a combination of protocols that the Rivet (Type) has to conform to. The `Rivet` is `Rivetable` if:

- `Mitigatable`: Receive requests to make anything that can go wrong less severe.
- `Parsable`: You get Dictionaries that you use to set the variables.
- `EnvironmentConfigurable`: We could get the data over the `Air` from a _production_ or a _development_ environment.
- `Mockable`: There is also a special case where the environment can be mocked. Than your request are loaded from local files _(dummy files)_
- `UniqueAble`: If your `AnyThing` is in a _collection_ you can find your entity by complying to `UniqueAble`

If you do the above (there are default implementation provided in the example). Then you could use the code like below.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

1. Create a Model object that complies to protocol `BaseModel`.
2. Create a class that complies to `Environment`.

### Swift

```swift
class Foo: Rivetable {
	// Implement protocols.
	// See GameScore class in Example project.
}

import AirRivet

do {
	try Air.retrieve({ (response : Foo) in
	  print(response)
  })
} catch {
	print("💣Error with request construction: \(error)💣")
}
```

### Objective-C

We use generics so you cannot directly use AirRivet in Objective-C. You can bypass this by writing a wrapper.

In our Example `GameScoreController` is the wrapper class.

```objective-C
// In build settings look at the Module Identifier.
// This is the one you should use to import swift files from the same target.

#import "AirRivet_Example-Swift.h"

GameScoreController * controller = [[GameScoreController alloc] init];
[controller retrieve:^(NSArray<Foo *> * _Nonnull response) {
	NSLog(@"%@", response);
} failure:^(NSError * _Nonnull error) {
	NSLog(@"%@", error);
}];
```
> *See "(project root)/Example" *

## Requirements

- iOS 8 or higher
- Because we use generics you can only use this pod in Swift only files. You can mix and Match with Objective-C but not with generic classes.  Types [More info](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-ID53)

## Installation

AirRivet is available through [CocoaPods](http://cocoapods.org) and the [Swift Package Manager](https://swift.org/package-manager/).

To install it with CocoaPods, add the following line to your Podfile:

```ruby
pod "AirRivet", '~> 0.2'
```

## Contribution

> Don't think to hard, try hard!

More info on the [contribution guidelines](https://github.com/icapps/ios-air-rivet/wiki/Contribution) wiki page.

## License

AirRivet is available under the MIT license. See the LICENSE file for more info.
