#
# Be sure to run `pod lib lint QVRWeekView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'QVRWeekView'
s.version          = '0.14.2'
s.summary          = 'QVRWeekView is a simple calendar week view with support for horizontal, vertical scrolling and zooming.'
s.swift_version    = '5'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'QVRWeekView is a framework which provides a calendar view that can be customized to display between 1 to 7 days in both portrait and landscape mode. Includes customization features to customize colours, fonts and sizes.'

s.homepage         = 'https://github.com/Quivr/iOS-Week-View'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Reinert' => 'reilemx@gmail.com' }
s.source           = { :git => 'https://github.com/Quivr/iOS-Week-View.git', :tag => 'v' + s.version.to_s }

s.ios.deployment_target = '9.0'

s.source_files = 'QVRWeekView/Classes/**/*.swift'
s.resources = 'QVRWeekView/Classes/Xibs/*.xib'

s.frameworks = 'UIKit'

end
