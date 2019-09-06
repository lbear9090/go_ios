//
//  Notifications.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import UserNotifications
import Crashlytics

extension AppDelegate {
    
    func registerForPushNotifications() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                CLSLogv("Remote notification authorization error: %@", getVaList([error.localizedDescription]))
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CLSLogv("Failed to register for remote notifications: %@", getVaList([error.localizedDescription]))
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        SHOAPIClient.shared.registerDeviceForPushNotifications(withToken: token) { object, error, code in
            if let error = error {
                CLSLogv("Failed to register device: %@", getVaList([error.localizedDescription]))
            } else if let device = object as? DeviceModel {
                UserDefaults.standard.set(device.pushToken, forKey: UserDefaultKey.pushNotificationToken)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let rootController = self.window?.rootViewController as? UITabBarController, SHOSessionManager.shared.isLoggedIn {
            
            if application.applicationState == .active && !self.shouldHandlePushNavigation {
                
                var unreadNotificationCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadNotificationCount)
                var unreadMessageCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadMessageCount)
                
                if let apsInfo = userInfo[PushConstants.APSKey] as? [AnyHashable: Any],
                    let extra = apsInfo[PushConstants.extraKey] as? [AnyHashable: Any],
                    let typeString = extra[PushConstants.notificationTypeKey] as? String,
                    let notificationType = NotificationType(rawValue: typeString) {
                    
                    if notificationType == .messageSent {
                        
                        if let messagesVC = rootController.currentViewController as? ConversationThreadViewController {
                            // Refresh messages
                            messagesVC.loadMessages(fromOffset: 0)
                        }
                        else if let conversationVC = rootController.currentViewController as? ConversationListViewController {
                            // Refresh conversations
                            conversationVC.refreshData()
                        }
                        else {
                            // Update chat tab badge
                            unreadMessageCount += 1
                            UserDefaults.standard.set(unreadMessageCount, forKey: UserDefaultKey.unreadMessageCount)
                            
                            if let chatTab = rootController.tabBar.items?[TabBarOrder.messaging.hashValue] {
                                chatTab.badgeValue = "\(unreadMessageCount)"
                            }
                        }
                        
                    } else {
                        
                        if let notificationsVC = rootController.currentViewController as? NotificationsListViewController {
                            // Refresh if notifications are already visible
                            notificationsVC.refreshData()
                        } else {
                            unreadNotificationCount += 1
                            UserDefaults.standard.set(unreadNotificationCount, forKey: UserDefaultKey.unreadNotificationCount)
                            
                            if let feedController = rootController.currentViewController as? ConfigurableNavBarButtons {
                                //FIXME: Update notification icon
                                feedController.configureNavBarButtons()
                            }
                        }
                    }
                }
                
                UIApplication.shared.applicationIconBadgeNumber = unreadNotificationCount + unreadMessageCount
                
            } else {
                if let apsInfo = userInfo[PushConstants.APSKey] as? [AnyHashable: Any],
                    let extra = apsInfo[PushConstants.extraKey] as? [AnyHashable: Any],
                    let typeString = extra[PushConstants.notificationTypeKey] as? String,
                    let notificationType = NotificationType(rawValue: typeString), notificationType == .messageSent,
                    let conversationID = extra["conversation_id"] as? Int64,
                    let messagesVC = ConversationThreadViewController(conversationID: conversationID) {
                    // Load Message thread
                    rootController.currentViewController?.navigationController?.pushViewController(messagesVC, animated: true)
                }
                else {
                    // Load notifications list
                    rootController.currentViewController?.navigationController?.pushViewController(NotificationsListViewController(), animated: true)
                }
            }
        }
    }
    
    func refreshAppIconBadgeNumber() {
        let unreadNotificationCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadNotificationCount)
        let unreadMessageCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadMessageCount)
        UIApplication.shared.applicationIconBadgeNumber = unreadNotificationCount + unreadMessageCount
    }
    
}
