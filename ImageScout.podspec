Pod::Spec.new do |s|
  s.name = "ImageScout"
  s.version = "3.0.0"
  s.summary = "Get the size and type of a remote image by downloading as little as possible."

  s.homepage = "https://github.com/kaishin/ImageScout"
  s.social_media_url = "http://twitter.com/kaishin"

  s.license = { :type => "MIT", :file => "LICENSE" }

  s.author = { "Reda Lemeden" => "git@redalemeden.com" }

  s.source = { :git => "https://github.com/kaishin/ImageScout.git", :tag => "v#{s.version}", :submodules => true }

  s.source_files  = "Sources", "Sources/**/*.swift"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
end
