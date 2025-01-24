#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint jitsi_meet_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'jitsi_meet_govar_flutter_sdk'
  s.version          = '10.3.0'
  s.summary          = 'A custom fork of jitsi_meet_flutter_sdk with some modifications.'
  s.description      = <<-DESC
Jitsi Meet Flutter SDK
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resources    = 'Assets/**/*'
  s.dependency 'Flutter'
  s.dependency 'JitsiMeetSDK', '10.3.0'
  s.platform = :ios, '15.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
