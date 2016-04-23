Pod::Spec.new do |s|
 
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.name = "STEMIHexapod"
  s.summary = "Framework for easier programming iOS App for STEMI hexapod robot"
  s.requires_arc = true
  s.version = "0.1.0"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Jasmin Abou Aldan" => "jasmin.aboualdan@gmail.com" }
  s.homepage = "https://github.com/jabou/STEMIHexapod"
  s.source = { :git => "https://github.com/jabou/STEMIHexapod.git", :tag => "#{s.version}"}
  s.framework = "UIKit"
  s.source_files = "STEMIHexapod/**/*.{swift}"
  #s.resources = "STEMIHexapod/**/*.{png,jpeg,jpg,storyboard,xib}"
end