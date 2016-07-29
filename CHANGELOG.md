# Faro

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
