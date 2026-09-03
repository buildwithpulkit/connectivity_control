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
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'connectivity_control_privacy' => ['connectivity_control/Sources/connectivity_control/PrivacyInfo.xcprivacy']}
end
