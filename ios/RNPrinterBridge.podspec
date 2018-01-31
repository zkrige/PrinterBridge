
Pod::Spec.new do |s|
  s.name         = "RNPrinterBridge"
  s.version      = "1.0.0"
  s.summary      = "RNPrinterBridge"
  s.description  = <<-DESC
                  This allows you to use a BT printer with RN
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "zkrige@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/zkrige/PrinterBridge.git", :tag => "master" }
  s.source_files  = "RNPrinterBridge/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "MBProgressHUD"

end

  