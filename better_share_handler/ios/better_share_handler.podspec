Pod::Spec.new do |s|
  s.name             = 'better_share_handler'
  s.version          = '1.0.0'
  s.summary          = 'Handle content shared to your Flutter app on iOS.'
  s.description      = 'iOS implementation of the better_share_handler Flutter plugin.'
  s.homepage         = 'https://github.com/sampaioxsamuel/share_handler'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Samuel' => 'sampaioxsamuel@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'better_share_handler/Sources/better_share_handler/**/*.swift'
  s.resource_bundles = {
    'better_share_handler_privacy' => ['better_share_handler/Sources/better_share_handler/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  s.dependency 'better_share_handler_models'
  s.platform = :ios, '14.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
