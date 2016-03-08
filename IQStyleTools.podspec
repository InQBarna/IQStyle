Pod::Spec.new do |s|
  s.name         = "IQStyleTools"
  s.version      = "0.0.1"
  s.summary      = "Helper tools for IQStyle"
  s.homepage     = "https://github.com/InQBarna/iq-style"
  s.author       = { "David Romacho" => "david.romacho@inqbarna.com" }
  s.license      = 'commercial'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.7'

  s.source       = { :git => "https://github.com/InQBarna/iq-style.git", :tag => "0.0.1" }
  s.source_files = 'IQStyleTools/*.{h,m}'

  s.requires_arc = true
end
