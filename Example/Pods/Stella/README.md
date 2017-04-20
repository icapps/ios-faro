![](./Images/StellaShield.jpg)

[![CI Status](http://img.shields.io/travis/icapps/ios-stella.svg?style=flat)](https://travis-ci.org/icapps/ios-stella)
[![License](https://img.shields.io/cocoapods/l/Stella.svg?style=flat)](http://cocoapods.org/pods/Stella)
[![Platform](https://img.shields.io/cocoapods/p/Stella.svg?style=flat)](http://cocoapods.org/pods/Stella)
[![Version](https://img.shields.io/cocoapods/v/Stella.svg?style=flat)](http://cocoapods.org/pods/Stella)
[![Language Swift 3.0](https://img.shields.io/badge/Language-Swift%203.0-orange.svg?style=flat)](https://swift.org)

> Stella contains a set of utilities that can be used during iOS development in Swift.

## TOC

- [Installation](#installation)
- [Features](#features)
  - [Defaults](#defaults)
  - [Keychain](#keychain)
  - [Localization](#localization)
  - [Printing](#printing)
- [Bucket List](#bucket-list)
- [Author](#author)
- [License](#license)

## Installation

Stella is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'Stella', '~> 1.1'
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

### Keychain

We have a cleaner way to use the `Keychain`. Define the user defaults by extending the `Keys` class.

```swift
extension Keys {
  // Writes a string object to the keychain with the 'stringValue' key.
  static let stringValue = Key<String?>("stringValue")
}
```

You can read/write the from/to the `Keychain` by using the `subscript` on the `Keychain` class.

```swift
Keychain[.stringValue] = "A string value"
print(Keychain[.stringValue]) // Prints 'A string value'
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

printQuestion("This is a question")
// The debug console will print `❓ This is an question.`
```
#### Print Levels

You can simply specify print levels like:

```swift
Output.level = .verbose
```

or to only print errors
```swift
Output.level = .error
```

Or just shut up everything, handy for in unit tests.

```swift
Output.level = .nothing
```
To see what is printed for what level look at the `PrintSpec`.

## Bucket List

Here is an overview what is on our todo list.

- [ ] The `sharedInstance` should be more configurable with a closure.
- [ ] Add keychain integration.

## Author

Jelle Vandebeeck, jelle@fousa.be

## License

Stella is available under the MIT license. See the LICENSE file for more info.
