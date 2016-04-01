# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AirRivet"
  s.version          = "0.0.2"
  s.summary          = "AirRivet is a web service stack to genericly convert JSON from a webservice to model objects."

  s.description      = <<-DESC
When you have a webservice to talk to parsing the data returned and handeling the errors can be a hassle. This is pod will help you build it more generic.
                       DESC

  s.homepage         = "https://github.com/icapps/AirRivet"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "StijnWillems" => "stijn.willems@icapps.com" }
  s.source           = { :git => "https://github.com/icapps/AirRivet.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/doozMen'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AirRivet' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
