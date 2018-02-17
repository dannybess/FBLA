//
//  Reminders.swift
//  DemoExpandingCollection
//
//  Created by Daniel Bessonov on 2/17/18.
//  Copyright © 2018 Alex K. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Reminder {
    
    class func getUserPermission(completion: @escaping (_ result: Bool) -> Void) {
        // define notificaiton variables
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert];
        // request permission
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                // not granted, ask on next launch (in App Delegate)
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }
    
    // type is either 'today' or 'overdue'
    class func setReminder(type: String, date : Date, book: Book) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        if(type == "today") {
            content.title = "Book due!"
            content.body = "Your book is due today! Please return it to avoid any potential fees!"
        }
        else {
            content.title = "Book overdue!"
            content.body = "Your book is overdue! Please return it as soon as possible; if not returned within the next couple days, the library will start to accumulate fees!"
        }
        // create date components
        let calendar = Calendar.current
        let units : Set<Calendar.Component> = [.day, .month, .year]
        let comps = calendar.dateComponents(units, from: date)
        // set date
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        // identifier is bookID + type
        let request = UNNotificationRequest(identifier: "\(book.bookID)+\(type)", content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
    
    // remove reminder (if user has returned book)
    class func removeReminder(type: String, book: Book) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(book.bookID)+\(type)", "\(book.bookID)+\(type)"])
    }
}
