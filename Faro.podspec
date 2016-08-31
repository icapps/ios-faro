Pod::Spec.new do |s|
  s.name             = 'Faro'
  s.version          = '1.0.0'
  s.summary          = 'Faro defines the contract to fetch data from an asynchronous source that can be mapped any model object.'

  s.description      = <<-DESC
__Faro__ is a service layer build in Swift by using generics. Its main starting point is the class `Air`. The idea is that you have `Air` which is a class that performs the request for an `Environment`. To do this it needs a Type called `Rivet` that can be handeled over the `Air` 🤔. So how do we make this `Rivet` Type?

`Any model object` can be a `Rivet` if they are `Rivetable`. `Rivetable` is a combination of protocols that the Rivet (Type) has to conform to. The `Rivet` is `Rivetable` if:

- `Mitigatable` -> Receive requests to make anything that can go wrong less severe.
- `Parsable` -> You get Dictionaries that you use to set the variables
- `EnvironmentConfigurable` -> We could get the data over the `Air` from a _production_ or a _development_ environment
- There is also a special case where the environment is `Mockable` then your request are loaded from local files _(dummy files)_
- `UniqueAble` -> If your `AnyThing` is in a _collection_ you can find your entity by complying to `UniqueAble`

If you do the above (there are default implementation provided in the example).
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
