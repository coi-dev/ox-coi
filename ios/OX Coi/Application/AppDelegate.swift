import Flutter
import UIKit

@UIApplicationMain
@objc
class AppDelegate: FlutterAppDelegate {

    private let INTENT_CHANNEL_NAME = "oxcoi.intent"
    var startString: String?

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.setupLogging()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        startString = url.absoluteString
        setupSharingMethodChannel()
        return true
    }

    private func setupSharingMethodChannel() {
        guard let controller = window.rootViewController as? FlutterViewController else {
            return
        }
        let methodChannel = FlutterMethodChannel(name: INTENT_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler {(call: FlutterMethodCall, result: FlutterResult) -> Void in
            if call.method.contains(Method.Invite.InviteLink) {
                if self.startString != nil || self.startString != "" {
                    result(self.startString)
                    self.startString = nil
                } else {
                    result(nil)
                }
            }
        }
    }

}
