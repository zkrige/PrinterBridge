Pod::Spec.new do |s|
  s.name         = "PrinterBridge"
  s.version      = "0.0.1"
  s.license      = "MIT"
  s.homepage     = "https://github.com/zkrige/PrinterBridge"
  s.authors      = { 'Zayin Krige' => 'zkrige@gmail.com' }
  s.summary      = "A React Native module that allows you to use a BT printer"
  s.source       = { :git => "https://github.com/zkrige/PrinterBridge" }
  s.source_files  = "ios/*.{h,m}"
  
  s.platform     = :ios, "9.0"
  s.dependency 'React'
  s.dependency 'MBProgressHUD'
end
