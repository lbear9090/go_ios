//
//  TabBarManager.swift
//  Go
//
//  Created by Lucky on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    static func configuredTabBarController() -> UITabBarController {
        
        let tabs: [TabBarItem] = [.newsFeedItem,
                                  .exploreItem,
                                  .addEventItem,
                                  .messagingItem,
                                  .profileItem]
        
        return self.configureTabBarController(tabBarItems: tabs)
    }
    
    static func configureTabBarController(tabBarItems: [TabBarItem]) -> UITabBarController {

        let tabBarController = UITabBarController()
        
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.isTranslucent = false
        
        let tabs = tabBarItems.sorted { (item1, item2) -> Bool in
            return item1.order.hashValue < item2.order.hashValue
        }
        
        var controllers = [UIViewController]()
        
        for item in tabs {
            controllers.append(item.configuredController())
        }
        
        tabBarController.viewControllers = controllers
        
        // Update chat tab badge
        if let chatTab = tabBarController.tabBar.items?[TabBarOrder.messaging.hashValue] {
            let unreadMessageCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadMessageCount)
            if unreadMessageCount > 0 {
                chatTab.badgeValue = "\(unreadMessageCount)"
            } else {
                chatTab.badgeValue = nil
            }
        }
        
        return tabBarController
    }
    
    var currentViewController: UIViewController? {
        if let navController = self.selectedViewController as? UINavigationController {
            return navController.topViewController
        }
        else {
            return self.selectedViewController
        }
    }
}

class GoTabBarDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if !(viewController is UINavigationController) {
            let navController = UINavigationController(rootViewController: CreateEventViewController())
            viewController.present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
