//
//  AppDelegate.swift
//  DemoExpandingCollection
//
//  Created by Alex K. on 25/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

//user for session
let user = User(schoolID: "123456", name: "Daniel", books: [])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureNavigationTabBar()
        FirebaseApp.configure()
        // set notif delegate
        UNUserNotificationCenter.current().delegate = self
        // get user defaults
        let defaults = UserDefaults.standard
        // not first launch
        if let permission = defaults.object(forKey: "permGranted") as? Bool {
            // perm exists and not granted
            if(permission == false) {
                Reminder.getUserPermission() {
                    result in
                    defaults.set(result, forKey: "permGranted")
                }
            }
        }
        // is first launch
        else {
            Reminder.getUserPermission() {
                result in
                defaults.set(result, forKey: "permGranted")
            }
        }
        print(UIApplication.shared.scheduledLocalNotifications)
        print("ASFASFYUHHHH")
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

extension AppDelegate {

    fileprivate func configureNavigationTabBar() {
        //transparent background
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true

        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 2)
        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.shadow: shadow,
        ]
    }
}
