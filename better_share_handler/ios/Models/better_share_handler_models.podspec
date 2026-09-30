Pod::Spec.new do |s|
  s.name             = 'better_share_handler_models'
  s.version          = '1.0.0'
  s.summary          = 'Share extension code for the better_share_handler plugin.'
  s.description      = 'Shared code so the Runner and Share Extension targets can both use better_share_handler.'
  s.homepage         = 'https://github.com/sampaioxsamuel/share_handler'
  s.license          = { :file => '../../LICENSE' }
  s.author           = { 'Samuel' => 'sampaioxsamuel@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = '../better_share_handler/Sources/better_share_handler_models/**/*.swift'
  s.resource_bundles = {
    'better_share_handler_models_privacy' => ['../better_share_handler/Sources/better_share_handler_models/PrivacyInfo.xcprivacy']
  }
  s.platform = :ios, '14.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
