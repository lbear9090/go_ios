//
//  NavBarButtonProtocols.swift
//  Go
//
//  Created by Killian Kenny on 28/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol ConfigurableNavBarButtons: AnyObject where Self: UIViewController {
    func configureNavBarButtons()
    var actions: StandardNavBarButtonActions? { get }
}

extension ConfigurableNavBarButtons {
    var actions: StandardNavBarButtonActions? {
        return nil
    }
}

extension ConfigurableNavBarButtons where Self: StandardNavBarButtonActions {
    
    func configureNavBarButtons() {
        let unreadCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadNotificationCount)
        let notificationButtonImage: UIImage = unreadCount > 0 ? .notificationUnreadIcon : .notificationIcon
        
        let notificationButton = UIBarButtonItem(image: notificationButtonImage,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(notificationButtonTapped))
        
        let searchButton = UIBarButtonItem(image: .searchIcon,
                                           style: .plain,
                                           target: self,
                                           action: #selector(searchButtonTapped))
        
        let findFriendsButton = UIBarButtonItem(image: .findFriendsNavBar,
                                                style: .plain,
                                                target: self,
                                                action: #selector(navigateToFindFriends))
        
        navigationItem.rightBarButtonItems = [notificationButton, searchButton]
        navigationItem.leftBarButtonItem = findFriendsButton
    }
    
    var actions: StandardNavBarButtonActions? {
        return self
    }
}

@objc protocol StandardNavBarButtonActions {
    @objc func searchButtonTapped()
    @objc func notificationButtonTapped()
    @objc func navigateToFindFriends()
}
