Pod::Spec.new do |s|
  s.name = "ImageScout"
  s.version = "1.0.0"
  s.summary = "Get the size and type of a remote image by downloading as little as possible."
  s.homepage = "https://github.com/kaishin/ImageScout"
  s.social_media_url = "http://twitter.com/kaishin"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Reda Lemeden" => "git@kaishin.haz.email" }
  s.source = { :git => "https://github.com/kaishin/ImageScout.git", :tag => "v#{s.version}", :submodules => true }
  s.ios.source_files = "Source/**/*.{h,swift}", "ImageScout-iOS/**/*.{h,swift}"
  s.osx.source_files = "Source/**/*.{h,swift}", "ImageScout-Mac/**/*.{h,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
end
