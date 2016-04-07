# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AirRivet"
  s.version          = "0.0.4"
  s.summary          = "AirRivet is a web service stack to genericly convert JSON from a webservice to model objects."

  s.description      = <<-DESC
When you have a webservice to talk to parsing the data returned and handeling the errors can be a hassle. This is pod will help you build it more generic.
We use a single principle to build the the Architecture of this service. Your projects model object are of a certain Type. This Type can conform to `BaseModel` protocol so it can be saved or retreived by a `RequestController`.

The goal is to create a service layer for iCapps that is independent of any underlying frameworks or models you use (like pod `Argo` or `ObjectMapper`).
                       DESC
 s.license          = 'MIT'
  s.homepage         = "https://github.com/icapps/ios-air-rivet"
  s.author           = { "Leroy" => "development@icapps.com" }
  s.source           = { :git => "https://github.com/icapps/ios-air-rivet.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/icapps'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AirRivet' => ['Pod/Assets/*.png']
  }
end
