Pod::Spec.new do |s|
  s.name             = 'Faro'
  s.version          = '1.0.0'
  s.summary          = 'Faro defines the contract to fetch data from an asynchronous source that can be mapped to any model object.'

  s.description      = <<-DESC
__Faro__ is a service layer built in Swift by using generics. We focussed on:
*Service*
* Service written to use Swift without using the Objective-C runtime
* Service cleanly encapsulates all the parameters to handle a network request in `Call`.
* Easily write a 'MockService' to load JSON from a local drive

*Automagically Parse*
* Use our Deserialization and Serialization operators to parse relations and properties

*Protocols*
* Because we use Protocols you can use any type including CoreData's `NSManagedObject` 💪🏼

*Mocking*
* Use `FaroService` singleton if you want to switch between data from the server or a file.
* Handy for unit tests 💪🏼
* Handy if API is not yet available 🤓

                       DESC
 s.license          = 'MIT'
  s.homepage         = 'https://github.com/icapps/ios-faro'
  s.author           = { 'Leroy Jenkins' => 'development@icapps.com' }
  s.source           = {
    git: 'https://github.com/icapps/ios-faro.git',
    tag: s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/icapps'

  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.requires_arc = true

  s.source_files = 'Sources/**/*'

end
