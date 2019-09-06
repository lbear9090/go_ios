//
//  ExploreContainerViewController.swift
//  Go
//
//  Created by Lucky on 09/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class ExploreContainerViewController: SegmentedControlViewController, ConfigurableNavBarButtons, StandardNavBarButtonActions {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureNavBarButtons()
    }
    
    @objc func searchButtonTapped() {
        let controller = SearchSegmentedControlViewController.searchConfiguration()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func notificationButtonTapped() {
        self.navigationController?.pushViewController(NotificationsListViewController(), animated: true)
    }
    
    @objc func navigateToFindFriends() {
        let controller = SearchSegmentedControlViewController.findFriendsConfiguration()
        controller.addNavBarLogo = false
        controller.title = "SETTINGS_FIND_FRIENDS".localized
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
