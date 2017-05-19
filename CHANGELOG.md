# Faro

## Version 1.0.13
* error printing with end of lines

## Version 1.0.12
* crash fix with json that could not be pretty printed.

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
* deprecating convenience functions on `Service`

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
