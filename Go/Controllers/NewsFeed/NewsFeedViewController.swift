//
//  NewsFeedViewController.swift
//  Go
//
//  Created by Lucky on 24/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class NewsFeedViewController: FeedViewController, ConfigurableNavBarButtons, StandardNavBarButtonActions {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavigationItemLogo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureNavBarButtons()
        
        if UserDefaults.standard.bool(forKey: UserDefaultKey.showAddFriendsPrompt) {
            UserDefaults.standard.set(false, forKey: UserDefaultKey.showAddFriendsPrompt)
            self.showAddFriendsPrompt()
        }
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
    
    // MARK: - Helpers
    
    private func showAddFriendsPrompt() {
        let addFriendsAction = UIAlertAction(title: "ADD_FRIENDS_PROMPT_ACCEPT".localized,
                                             style: .default) { [unowned self] action in
                                                self.navigateToFindFriends()
        }
        
        let notNowAction = UIAlertAction(title: "ADD_FRIENDS_PROMPT_REJECT".localized,
                                         style: .default) { [unowned self] action in
                                            self.dismiss(animated: true)
        }
        
        let addFriendsAlert = UIViewController.alertWith(title: "ADD_FRIENDS_PROMPT_TITLE".localized,
                                                         message: "ADD_FRIENDS_PROMPT_MSG".localized,
                                                         actions: [addFriendsAction, notNowAction])

        self.present(addFriendsAlert, animated: true)
    }
    
}
