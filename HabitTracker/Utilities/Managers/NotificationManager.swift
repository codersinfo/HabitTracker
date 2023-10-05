//
//  NotificationManager.swift
//  HabitTracker
//
//  Created by Priya Shankar on 05/10/23.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, err in
            if let error = err {
                print("Error \(error)")
            } else {
                print("Success")
            }
        }
    }
}
