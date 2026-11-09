Pod::Spec.new do |s|
  s.name             = 'dynamic_color'
  s.authors          = 'Material Flutter team + Ebrahim Byagowi'
  s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }
  s.homepage         = 'https://github.com/material-foundation/flutter-packages/tree/main/packages/dynamic_color'
  s.summary          = 'Retrieves accent color'
  s.version          = '0.0.3'
  s.source           = { :http => 'https://github.com/material-foundation/flutter-packages/tree/main/packages/dynamic_color' }
  s.source_files = 'dynamic_color/Sources/dynamic_color/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  s.resource_bundles = {'dynamic_color_macos_privacy' => ['dynamic_color/Sources/dynamic_color/PrivacyInfo.xcprivacy']}
end
