# Stella

[![CI Status](http://img.shields.io/travis/icapps/ios-stella.svg?style=flat)](https://travis-ci.org/icapps/ios-stella)
[![License](https://img.shields.io/cocoapods/l/Stella.svg?style=flat)](http://cocoapods.org/pods/Stella)
[![Platform](https://img.shields.io/cocoapods/p/Stella.svg?style=flat)](http://cocoapods.org/pods/Stella)
[![Version](https://img.shields.io/cocoapods/v/Stella.svg?style=flat)](http://cocoapods.org/pods/Stella)
[![Language Swift 2.2](https://img.shields.io/badge/Language-Swift%202.2-orange.svg?style=flat)](https://swift.org)

> Stella contains a set of utilities that can be used during iOS development in Swift.

## TOC

- [Installation](#installation)
- [Features](#features)
  - [Defaults](#defaults)
  - [Localization](#localization)
  - [Printing](#printing)
  - [Threading](#threading)
- [Bucket List](#bucket-list)
- [Author](#author)
- [License](#license)

## Installation

Stella is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'Stella', '~> 0.4'
```

## Features

### Defaults

We have a cleaner way to use `NSUserDefaults`. Define the user defaults by extending the `DefaultsKeys` class.

```swift
extension DefaultsKeys {
  // Writes a string object to the defaults with the 'stringValue' key.
  static let stringValue = DefaultsKey<String?>("stringValue")
  // Writes an integer to the defaults with the 'integerValue' key.
  static let integerValue = DefaultsKey<Int?>("integerValue")
  // Writes a double to the defaults with the 'doubleValue' key.
  static let doubleValue = DefaultsKey<Double?>("doubleValue")
  // Writes a float to the defaults with the 'floatValue' key.
  static let floatValue = DefaultsKey<Float?>("floatValue")
  // Writes a bool to the defaults with the 'booleanValue' key.
  static let booleanValue = DefaultsKey<Bool?>("booleanValue")
  // Writes a date object to the defaults with the 'dateValue' key.
  static let dateValue = DefaultsKey<NSDate?>("dateValue")
}
```

You can read/write the from/to the `NSUserDefaults` by using the `subscript` on the `Defaults` class.

```swift
Defaults[.stringValue] = "A string value"
print(Defaults[.stringValue]) // Prints 'A string value'

Defaults[.integerValue] = 123
print(Defaults[.integerValue]) // Prints '123'

Defaults[.doubleValue] = 123.123
print(Defaults[.doubleValue]) // Prints '123.123'

Defaults[.floatValue] = 123.321
print(Defaults[.floatValue]) // Prints '123.312'

Defaults[.booleanValue] = true
print(Defaults[.booleanValue]) // Prints 'true'

Defaults[.dateValue] = NSDate()
print(Defaults[.dateValue]) // Prints '1996-12-19T16:39:57-08:00'
```

### Localization

Localize a key in no time with this handy localization function.

```swift
let key = "this_is_your_localization_key"
print(key.localizedString)
// The debug console will print the localized
// string found in your .strings file.
```

### Printing

Add something extra to your debug output. There are *three* extra functions available for you to use.

```swift
printAction("This is a user action.")
// The debug console will print `🎯 This is a user action.`

printBreadcrumb("This is your breadcrumb.")
// The debug console will print `🍞 This is your breadcrumb.`

printError("This is an error.")
// The debug console will print `🔥 This is an error.`
```

### Threading

Perform block on the main or on the background queue more easily.

```swift
dispatch_on_main {
  // Perform this code on the main thread.
}

dispatch_on_main(after: 2) {
  // Perform this code on the main thread after 2 seconds.
}

dispatch_in_background {
  // Perform this code on a background thread.
}

dispatch_wait { completion in
  // Perform an asynchronous call to a web service for example.
  performCall {
    // Notify the `dispatch_wait` that the asynchronous call finished it's execution.
    completion()
  }
}
```

## Bucket List

Here is an overview what is on our todo list.

- [ ] The `sharedInstance` should be more configurable with a closure.
- [ ] Add keychain integration.

## Author

Jelle Vandebeeck, jelle@fousa.be

## License

Stella is available under the MIT license. See the LICENSE file for more info.
