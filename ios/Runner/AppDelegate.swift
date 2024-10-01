import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

//       if #available(iOS 10.0, *) {
//         UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//       }

      GeneratedPluginRegistrant.register(with: self)
      GMSServices.provideAPIKey("AIzaSyABUvens2qim4JrYbbgFoNfUHiZ-MwYl_Y")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
