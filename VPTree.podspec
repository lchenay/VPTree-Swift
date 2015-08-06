Pod::Spec.new do |s|
  s.name = "VPTree"
  s.version = "0.0.6"

  s.source = { :git => "https://github.com/lchenay/VPTree-Swift" }
  s.source_files = "VPTree/VPTree/*"
  s.frameworks = "Foundation"
  s.requires_arc = true
end
