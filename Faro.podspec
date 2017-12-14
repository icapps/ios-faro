Pod::Spec.new do |s|
  s.name             = 'Faro'
  s.version          = '3.0'
  s.summary          = 'Faro defines the contract to fetch data from an asynchronous source that can be mapped to any model object.'

  s.description      = <<-DESC
_Our goal with Faro is:

* Decode objects from JSON data returned from any service.
* Easy to debug errors and logs in the console
* Simplify security setup
                       DESC
 s.license          = 'MIT'
  s.homepage         = 'https://github.com/icapps/ios-faro'
  s.author           = { 'Leroy Jenkins' => 'development@icapps.com' }
  s.source           = {
    git: 'https://github.com/icapps/ios-faro.git',
    tag: s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/icapps'

  s.ios.deployment_target     = '9.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '3.0'

  s.requires_arc = true

  s.source_files = 'Sources/**/*'

end
