platform :ios, '7.0'
inhibit_all_warnings!

def pods
  pod 'AFNetworking', '~> 2.2'
  pod 'NYXImagesKit', '~> 2.3'
  pod 'FXKeychain', '~> 1.5'
  pod 'BlocksKit', '~> 2.2.0'
  pod 'NSString-Hashes', '~> 1.2.1'
  pod 'FrameAccessor', '~> 1.3.2'
  pod 'MWFeedParser', '~> 1.0.1'
  pod 'RegexKitLite', '~> 4.0'
  pod 'MBProgressHUD', '~> 0.8'
end

  post_install do |installer_representation|
      installer_representation.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['ARCHS'] = 'armv7 arm64'
          end
      end
  end

target "v2ex-dev" do
  pods
end

target "v2ex" do
  pods
end
