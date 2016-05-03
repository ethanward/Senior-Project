# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'

target 'CSCI490 App2' do
	pod "FacebookImagePicker"
    pod "FBSDKCoreKit"
    pod "FBSDKLoginKit"
    pod "Koloda"
    pod "SlackTextViewController"
    pod "SnapKit"
    pod "SDWebImage"
    
#    pod 'TwilioIPMessagingClient', :podspec => 'https://media.twiliocdn.com/sdk/rtc/ios/ip-messaging/v0.13/TwilioIPMessagingClient.podspec'
#    pod 'TwilioCommon', :podspec => 'https://media.twiliocdn.com/sdk/rtc/ios/common/v0.1/TwilioCommon.podspec'
end

target 'CSCI490 App2Tests' do

end

target 'CSCI490 App2UITests' do

end

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end
    
