//
//  AppDelegate.swift
//  Xchangerator
//
//  Created by 张一唯 on 2020-01-21.
//  Copyright © 2020 YYES. All rights reserved.
//

import Firebase
import FirebaseMessaging
import FirebaseUI
import NotificationBannerSwift
import SwiftyJSON
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,
    UNUserNotificationCenterDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // [START default_firestore]
        FirebaseApp.configure()

        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]

        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        // [END register_for_notifications]

        // //  Remove notification
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        var viewController = UIViewController()
//        if (launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary) != nil {
//                viewController = storyBoard.instantiateViewController(withIdentifier: "storyboardIdentifier") // user tap notification
//                application.applicationIconBadgeNumber = 0 // For Clear Badge Counts
//                let center = UNUserNotificationCenter.current()
//                center.removeAllDeliveredNotifications()
//        } else {
//                viewController = storyBoard.instantiateViewController(withIdentifier: "storyboardIdentifier") // User not tap notificaiton
//        }
//        self.window?.rootViewController = viewController
//        self.window?.makeKeyAndVisible()

        return true
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.debug("Message ID: \(messageID)")
        }
        // TODO: Handle data part of notification
        let apsJSON = JSON(userInfo["aps"] ?? [])
        let title = apsJSON["alert"]["title"].string ?? "Title"
        let body = apsJSON["alert"]["body"].string ?? "You received a message."
        let banner = FloatingNotificationBanner(title: "\(title)",
                                                subtitle: "\(body)", style: .info)
        banner.show()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.error("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

//
//    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
//      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
//        return true
//      }
//      // other URL handling goes here.
//      return false
//    }
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
}

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Logger.debug("Firebase device token received: \(fcmToken)")
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        UserRepoManager().storeCurDeviceToken(forUserID: "current", token: fcmToken)
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    // [END refresh_token]

    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//    let banner = NotificationBanner(title: title, subtitle: subtitle, style: .success)
//    banner.show()
//        print("Received data message: \(remoteMessage.appData)")
    }

    // [END ios_10_data_message]
}
