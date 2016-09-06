Pod::Spec.new do |s|
  s.name = "VPTree"
  s.version = "0.0.7"

  s.source = { :git => "https://github.com/lchenay/VPTree-Swift" }
  s.source_files = "VPTree/VPTree/*"
  s.frameworks = "Foundation"
  s.requires_arc = true
  s.authors = { 'Laurent Chenay' => 'lchenay@gmail.com' }
  s.homepage = "https://github.com/lchenay/VPTree-Swift"
  s.summary = "A quick implementation of VPTree in swift"
end
