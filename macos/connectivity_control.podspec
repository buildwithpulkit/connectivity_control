#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint connectivity_control.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'connectivity_control'
  s.version          = '1.1.0'
  s.summary          = 'A Flutter plugin to inspect active network interfaces and their capabilities.'
  s.description      = <<-DESC
A Flutter plugin to inspect active network interfaces and their internet capability, validation state, metering, and bandwidth.
                       DESC
  s.homepage         = 'https://github.com/buildwithpulkit/connectivity_control'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pulkit Agarwal' => 'support@pulkitagarwal.me' }
  s.source           = { :path => '.' }
  s.source_files = 'connectivity_control/Sources/connectivity_control/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.15'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
