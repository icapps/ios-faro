# AirRivet

## Version 0.5.2
* Fixed problem at startup when unique value was not present

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
