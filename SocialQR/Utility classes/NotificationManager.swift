//
//  NotificationManager.swift
//  SocialQR
//
//  Created by Rahul Yedida on 1/18/21.
//
// from https://blckbirds.com/post/local-notifications-swiftui/

import Foundation
import SwiftUI

class NotificationManager: ObservableObject {
    var notifications = [Notification]()
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
            } else {
                print("Notifications not permitted")
            }
        }
    }
    
    func sendNotification(title: String, subtitle: String?, body: String, launchIn: Double) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.body = body
        
        let imageName = "logo"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: launchIn, repeats: false)
        let request = UNNotificationRequest(identifier: "socialQRNotif", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
