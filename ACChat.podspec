#
# Be sure to run `pod lib lint ACChat.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ACChat'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ACChat. It is a simple to use XMPP messaging sdk with customisable key mapping'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A short description of ACChat. It is a simple to use XMPP messaging sdk with customisable key mapping
                       DESC

  s.homepage         = 'https://github.com/spourteymour/ACMessaging'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
 s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'S Pourtaymour' => 'sepand_pourteymour@live.co.uk' }
  s.source           = { :git => 'https://github.com/spourteymour/ACMessaging.git', :branch => 'add/createFramework', :tag => 'experimental-framework-0.1.1' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.module_name   = 'ACChat'
  s.swift_version = '4.0'

  s.ios.deployment_target = '8.0'
#  s.dependency 'XMPPFramework'

  s.source_files = 'ACMessaging/**/*.swift'
  
  s.vendored_frameworks =
  s.vendored_frameworks =
  s.vendored_frameworks =
  s.vendored_frameworks =
  
  # s.resource_bundles = {
  #   'ACChat' => ['ACChat/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
