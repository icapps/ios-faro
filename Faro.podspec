Pod::Spec.new do |s|
  s.name             = 'Faro'
  s.version          = '1.0.0'
  s.summary          = 'Faro defines the contract to fetch data from an asynchronous source that can be mapped any model object.'

  s.description      = <<-DESC
__Faro__ is a service layer build in Swift by using generics. 
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
