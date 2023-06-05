#
# Be sure to run `pod lib lint SwiftyInterceptor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyInterceptor'
  s.version          = '0.1.1'
  s.summary          = 'Network debugging and mock server for UI testing'
  s.homepage         = 'https://github.com/chittapon/SwiftyInterceptor'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chittapon Thongchim' => 'papcoe@gmail.com' }
  s.source           = { http: "#{s.homepage}/releases/download/#{s.version}/Interceptor.zip" }
  s.ios.deployment_target = '10.0'
  s.source_files = 'Sources/*.{swift,h,m}'
  s.preserve_paths = '*'
  s.swift_version = "5.0"
end
