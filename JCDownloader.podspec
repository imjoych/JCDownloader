Pod::Spec.new do |s|
  s.name         = 'JCDownloader'
  s.version      = '0.1.5'
  s.license      = 'MIT'
  s.summary      = 'A useful iOS download framework based on AFNetworking.'
  s.homepage     = 'https://github.com/Boych/JCDownloader'
  s.author       = { 'ChenJianjun' => 'ioschen@foxmail.com' }
  s.source       = { :git => 'https://github.com/Boych/JCDownloader.git', :tag => s.version.to_s }
  s.source_files = 'JCDownloader/*.{h,m}'
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 3.1.0'

end
