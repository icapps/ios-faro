# Faro

## Version 2.0.7
* integrate fix from 1.0.11

## Version 2.0.5 & 2.0.6
* Array's or Set's of `RawRepresentable`'s can be parsed by create functions
* Array's or Set's of primitive types

## Version 2.0.4
* removed redundant prints for `DeprecatedService`

## Version 2.0.2 & 2.0.3
Minor fix to Readme file

## Version 2.0.1

* You can now do a multipart post
* Removed `Deserializable` in favor of `JSONDeserialisable`
  * it appeared to difficult ot maintain both as in version 2.0
* Removed `Updateable` in favor of `JSONUpdateable`
  * it was difficult to maintain both

How to migrate:
* Comming from 1.0.0
  * Change all instances that implement `Deserializable` to `JSONDeserialisable`
  * Rename `init?(from raw: Any)` to `init(_ raw: [String: Any]) throws`
  * Handle throws instead of nil where you used the previous init
    * hint: If you do not want to handle the throws in old code that react to nil you can `let model = try? Foo()`
  * Change all instances that implement `Updateable` to `JSONUpdateable`
* Comming from 2.0.0
  * remove all `init?(from raw: Any)` and `Deserializable`

## Version 2.0.0

* Attempt to make error more descriptive
* Removed confusing Perform functions and added 2 functions `single...` `collection`
* Made it more descriptive that a request does not expect a json response.
* Moved away from result Enmum in favor of throws

*! Warning this is a breaking change*

* Parse functions
  * `parse(.. rename` -> `create(...`
* Operator rename:
  * DeserializeOperators `<->` to `|<`
  * SerializeOperators `<->` to `<|`
* Operators on models require the model to adopt 'Updatable'
  * This is done so it is more clear we create a new instance or update an existing one.

### Service has been deprecated
How to migrate:
* Original `Service` class is renamed to `DeprecatedService` and tagged. Rename all instances you have of Service to `DeprecatedService`
* Use the new `Service` for any new request you make.

### Deserialisable and Serialisable
We favor the use of `JSONDeserialisable` and `JSONSerialisable`
How to migrate:

* For new requests that use the new `Service` use `JSONDeserialisable` and `JSONSerialisable`
* `Deserialisable and `Serialisable` will still be available in the future as we might implement a more parsing from XML

### Result to DeprecatedResult

`DeprecatedService` still uses DeprecatedResult.
How to migrate:

* New requests should use the new `Result`
* Old request should rename `Result` to `DeprecatedResult`

### FaroService renamed to FaroSingelton
You can still use a singleton but the confusing name FaroService is now gone
How to migrate:

* Rename FaroService to FaroDeprecatedSingleton
* For new projects use FaroSingelton

---
## Version 1.0.11
* fixes issue with Header fields not being overwritten

## Version 1.0.10
* Added way to Authenticate via `Authenticatable`
* Added Secure url session to centralize security
* Minor spelling fixes

## Version 1.0.9
* Using URLRequest default timeout instead of 10 seconds

## Version 1.0.8
*  Array of primitive types Deserialisable

## Version 1.0.7
* using to swiftlint

## Version 1.0.6
* deprecating convinience functions on `Service`

## Version 1.0.5
Minor changes.
* Open up mockservice url
* better error logs

## Version 1.0.4
* `ServiceQueue` reports failures
* `Parameters` inserts `.urlComponents` sorted

## Version 1.0.3
* Disabled JSON mock data reading for watchOS

## Version 1.0.1
* Added a queue for basic queuing. You get to fire request and get a done when everything is done.
* Added example on how to use enums for parsing JSON
* Moving to buddybuild
* ... Feel free to comment or ad.


## Version 1.0.0
* Convenience methods that do not use a switch as a result
* Support for mocking a service request or an whole session
### **WARNING**
Version 1.0.0 is not compatible with 0.7.2. All the functions, classes, protocols, ... that we no longer support have been marked with a ```@available(*, deprecated=1.0.0, message="use the Bar class")``` attribute.

In the previous versions to fire a service request you used the `Air` class. Now you should use the `Service` class.

* First implementation after major changes (read more in the ReadMe)

---
## Version 0.7.3
* fixed #42 to add FaroParent and FaroParentSwift to make setup possible via inheritance.
## Version 0.7.2
* renamed everything Faro
* Distributable to CocoaPods via travis

## Version 0.7.1
* deprecating AirRivet in favor of the name Faro
* Renaming the github repo to Faro
* Pointing the podspec to the renamed repo

## Version 0.6.1
* minor fix

## Version 0.6.0
### WARNING

Breaking changes

* CoreDataFromPopulatedSqlite works with version string to solve problems with update

## Version 0.5.13
* CoreDataPopulatedSqlite now throws when you forget to add a sqlite file to the application bundle
*
## Version 0.5.12
* fixed problem with unit tests and singleton of managedObjectContext

## Version 0.5.11
* fixes and documentation for core data unit tests

## Version 0.5.10
* renames in core data

## Version 0.5.9
* made stuff public

## Version 0.5.8
* added some convinience methods for core data

## Version 0.5.7
* fixed crash in unique lookup

## Version 0.5.6
* Fix a bug when buiding for watchOS.

## Version 0.5.5
* Added support for OS X, watchOS and tvOS.

## Version 0.5.4
* Added transformer that can store JSON files
* Update unit test imports
* Updated ReadMe

## Version 0.5.3
* Added utility function to fetch unique entities from core data

## Version 0.5.0
* Added support for CoreData
* Mitigator Example with a non printing Version
* Introduced MapError

## Version 0.4.3
* Usable with CoreData. Unfortunately we have to expose some of the CoreData internals in AirRivet. Otherwise Rivetable instances would not be testable.

## Version 0.4.2
* We initialized a lot. This was due to an override problem with static methods. This has now been fixed. The TransformController is the only object responsible of initializing instances
* `Parsable` protocol now has a throwable initializer. This is to make it possible to use the protocol for `NSManagedObject` subclasses.


## Version 0.4.1

* Made function on TransformController public that we could use to intercept the data before it is mapped to the object.

## Version 0.3.0

* Add a Swift package.
* Use CocoaPods version 1.0.

## Version 0.2.0

* Integrated the automated build system.
