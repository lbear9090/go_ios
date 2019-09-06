//
//  UserProfileViewController.swift
//  Go
//
//  Created by Lucky on 27/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class UserProfileViewController: CurrentUserProfileViewController {

    let userId: Int64
    private var user: UserModel? {
        didSet {
            self.tableView.reloadData()
            if let user = self.user {
                self.userName = user.displayName
                self.tableHeader.populate(with: user)
                self.tableHeader.autoresize(for: self.view.bounds.size)
            }
        }
    }
    lazy var friendManager = FriendshipManager(with: self)
    lazy var optionsManager = OptionsAlertManager(for: self)
    
    override var emptyStateText: String {
        return "EMPTY_STATE_MESSAGE".localized
    }
    
    override lazy var tableHeader: CurrentUserProfileHeaderView = {
        let header = UserProfileHeaderView()
        header.autoresize(for: self.view.bounds.size)
        header.friendButton.setManager(self.friendManager)
        header.friendLabelTapHandler = { [unowned self] in
            self.presentFriendsList()
        }
        return header
    }()
    
    init(userId: Int64) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
        self.endpointType = .userWithId(userId)
    }
    
    init(userModel: UserModel) {
        self.user = userModel
        self.userId = userModel.userId
        super.init(nibName: nil, bundle: nil)
        self.endpointType = .userWithId(userId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureNavigationItem() {
        let optionsButton = UIBarButtonItem(image: .actionButton,
                                             style: .plain,
                                             target: self,
                                             action: #selector(optionsButtonTapped))
        self.navigationItem.rightBarButtonItem = optionsButton
    }
    
    override func getCachedUser() {
        if let user = CacheManager.getUserWithId(userId) {
            self.userName = user.displayName
            self.tableHeader.populate(with: user)
            self.tableHeader.autoresize(for: self.view.bounds.size)
        }
        self.refreshUser(showSpinner: false)
    }
    
    // MARK: - User actions
    
    @objc private func optionsButtonTapped() {
        self.optionsManager.showOptions(forUserId: self.userId)
    }
    
    private func presentFriendsList() {
        let controller = SearchSegmentedControlViewController.friendsConfiguration(for: self.userId)
        controller.addNavBarLogo = false
        controller.title = self.userName
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Static init method
    static func controllerForUserWithId(userId: Int64, userModel: UserModel? = nil) -> CurrentUserProfileViewController {
        let currentUserId = UserDefaults.standard.integer(forKey: UserDefaultKey.currentUserId)
        if currentUserId == userId {
            return CurrentUserProfileViewController()
        } else {
            return userModel != nil ? UserProfileViewController(userModel: userModel!) : UserProfileViewController(userId: userId)
        }
    }
    
}
