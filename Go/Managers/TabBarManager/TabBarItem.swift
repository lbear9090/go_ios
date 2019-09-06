//
//  TabBarItem.swift
//  Go
//
//  Created by Lucky on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

enum TabBarOrder {
    case newsFeed
    case feed
    case addEvent
    case messaging
    case profile
    
    var title: String {
        switch self {
        case .newsFeed:
            return "TABBAR_NEWSFEED".localized
            
        case .feed:
            return "TABBAR_TRENDING".localized
            
        case .addEvent:
            return "TABBAR_CREATE".localized
            
        case .messaging:
            return "TABBAR_CHAT".localized
            
        case .profile:
            return "TABBAR_PROFILE".localized
        }
    }
}

struct TabBarItem {
    let controller: UIViewController
    let selectedImage: UIImage
    let unselectedImage: UIImage
    let shortcutImage: UIApplicationShortcutIcon?
    let order: TabBarOrder
    let selectedColor: UIColor
    let unselectedColor: UIColor
    
    public func configuredController() -> UIViewController {
        controller.tabBarItem.image = self.unselectedImage
        controller.tabBarItem.selectedImage = self.selectedImage
        controller.tabBarItem.title = self.order.title
        controller.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : self.selectedColor], for: .selected)
        controller.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : self.unselectedColor], for: .normal)
        
        if self.order == .addEvent {
            return controller
        }
        
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }
}

extension TabBarItem {
    
    public static var newsFeedItem: TabBarItem {
        return TabBarItem(controller: NewsFeedViewController(with: NewsfeedDataProvider()),
                          selectedImage: UIImage.newsFeedTabSelected.withRenderingMode(.alwaysOriginal),
                          unselectedImage: UIImage.newsFeedTab.withRenderingMode(.alwaysOriginal),
                          shortcutImage: nil,
                          order: .newsFeed,
                          selectedColor: .newsFeedSelected,
                          unselectedColor: .newsFeedUnselected)
    }
    
    public static var exploreItem: TabBarItem {
        return TabBarItem(controller: exploreController,
                          selectedImage: UIImage.exploreTabSelected.withRenderingMode(.alwaysOriginal),
                          unselectedImage: UIImage.exploreTab.withRenderingMode(.alwaysOriginal),
                          shortcutImage: nil,
                          order: .feed,
                          selectedColor: .feedSelected,
                          unselectedColor: .feedUnselected)
    }
    
    public static var addEventItem: TabBarItem {
        return TabBarItem(controller: UIViewController(),
                          selectedImage: UIImage.addEventTabSelected.withRenderingMode(.alwaysOriginal),
                          unselectedImage: UIImage.addEventTab.withRenderingMode(.alwaysOriginal),
                          shortcutImage: nil,
                          order: .addEvent,
                          selectedColor: .createSelected,
                          unselectedColor: .createUnselected)
    }
    
    public static var messagingItem: TabBarItem {
        return TabBarItem(controller: ConversationListViewController(),
                          selectedImage: UIImage.messagingTabSelected.withRenderingMode(.alwaysOriginal),
                          unselectedImage: UIImage.messagingTab.withRenderingMode(.alwaysOriginal),
                          shortcutImage: nil,
                          order: .messaging,
                          selectedColor: .chatSelected,
                          unselectedColor: .chatUnselected)
    }
    
    
    public static var profileItem: TabBarItem {
        return TabBarItem(controller: CurrentUserProfileViewController(),
                          selectedImage: UIImage.profileTabSelected.withRenderingMode(.alwaysOriginal),
                          unselectedImage: UIImage.profileTab.withRenderingMode(.alwaysOriginal),
                          shortcutImage: nil,
                          order: .profile,
                          selectedColor: .profileSelected,
                          unselectedColor: .profileUnselected)
    }
    
    private static var exploreController: UIViewController {
        let friendsMapController = FeedMapContainerViewController(feedController: FilterableFeedViewController(with: FriendsFeedMapDataProvider()),
                                                                  mapController: MapViewController(with: FriendsFeedMapDataProvider()),
                                                                  segmentTitle: "FRIENDS_TITLE".localized)
        
        let groupsMapController = FeedMapContainerViewController(feedController: FilterableFeedViewController(with: GroupsFeedMapDataProvider()),
                                                                 mapController: MapViewController(with: GroupsFeedMapDataProvider()),
                                                                 segmentTitle: "INTERESTS_TITLE".localized)
        
        return ExploreContainerViewController(with: [FeaturedViewController(), friendsMapController, groupsMapController])
    }
}
