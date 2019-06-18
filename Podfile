platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'WeatherApp' do
  # Uncomment this line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  inhibit_all_warnings!
  
  pod 'SVProgressHUD',         '~> 2.2.5'

  # Networking
  pod 'Alamofire',             '~> 4.7'
  pod 'AlamofireObjectMapper', '~> 5.0'
  pod 'ObjectMapper',          '~> 3.3.0'
  pod 'PromiseKit',            '~> 6.8'
 

  target 'WeatherAppTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
    end
  end
end

