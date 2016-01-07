Pod::Spec.new do |s|
  s.name         = "EasyTableView"
  s.version      = “2.0.1”
  s.summary      = "Horizontal and vertical scrolling table views for iOS."
  s.homepage     = "https://github.com/alekseyn/EasyTableView"
  s.license      = { :type => "MIT" }
  s.author       = { "Aleksey Novicov" => "aleksey@yodelcode.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/alekseyn/EasyTableView.git", :tag => “2.0.1” }
  s.source_files = "Classes/EasyTableView.{h,m}"
  s.requires_arc = true
end
