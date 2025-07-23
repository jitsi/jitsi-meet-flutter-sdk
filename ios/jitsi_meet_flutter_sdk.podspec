#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint jitsi_meet_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'jitsi_meet_flutter_sdk'
  s.version          = '11.3.1'
  s.summary          = 'Jitsi Meet Flutter SDK'
  s.description      = <<-DESC
Jitsi Meet Flutter SDK
                       DESC
  s.homepage         = 'https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-flutter-sdk'
  s.authors          = 'Jitsi Meet'
  s.license          = { :file => '../LICENSE' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'JitsiMeetSDK', '11.3.1'
  s.platform = :ios, '15.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
