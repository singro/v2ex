platform :ios, '7.0'
inhibit_all_warnings!

pod 'AFNetworking', '~> 2.2.0'
pod 'NYXImagesKit', '~> 2.3'
pod 'FXKeychain', '~> 1.5'
pod 'BlocksKit', '~> 2.2.0'
pod 'NSString-Hashes', '~> 1.2.1'
pod 'FrameAccessor', '~> 1.3.2'
pod 'MWFeedParser', '~> 1.0.1'
pod 'RegexKitLite', '~> 4.0'
pod 'MBProgressHUD', '~> 0.8'

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ARCHS'] = 'armv7 arm64'
        end
    end
end
