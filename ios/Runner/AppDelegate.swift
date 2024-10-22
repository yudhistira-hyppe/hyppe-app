import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    if (!UserDefaults.standard.bool(forKey: "Notification")) {
         UIApplication.shared.cancelAllLocalNotifications()
         UserDefaults.standard.set(true, forKey: "Notification")
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Prevent screen capture and screen recording
  // override func applicationWillResignActive(
  //   _ application: UIApplication
  // ) {
  //   self.window.isHidden = true;
  // }
  
  // override func applicationDidBecomeActive(
  //   _ application: UIApplication
  // ) {
  //   self.window.isHidden = false;
  // }
}
