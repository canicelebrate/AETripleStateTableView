Pod::Spec.new do |s|
  s.name             = "AETripleStateTableView"
  s.version          = "1.1.0"
  s.summary          = "A lightweight, customizable subclass of UITableView that supports triple states(loading, no data and normal)"
  s.homepage         = "https://github.com/canicelebrate/AETripleStateTableView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "William Wang" => "canicelebrate@gmail.com" }
  s.source           = { :git => "https://github.com/canicelebrate/AETripleStateTableView.git", :tag => s.version }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

s.source_files = 'AETripleStateTableView/*.{h,m}'
s.public_header_files = "AETripleStateTableView/AETripleStateTableView.h"
#s.resources = "AETripleStateTableView/*.xcassets"
end
