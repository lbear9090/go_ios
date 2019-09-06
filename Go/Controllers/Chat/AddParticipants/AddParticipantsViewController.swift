//
//  AddFriendsViewController.swift
//  Go
//
//  Created by Lee Whelan on 24/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class AddParticipantsViewController: SelectFriendsViewController {
    
    override var selectedUsers: [UserModel] {
        didSet {
            self.nextButton.isEnabled = selectedUsers.count > 0
        }
    }
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "CHAT_NEW_GROUP_NEXT".localized,
                                     style: .plain,
                                     target: self,
                                     action: #selector(nextTapped))
        button.tintColor = .green
        button.isEnabled = false
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.nextButton.isEnabled = self.selectedUsers.count > 0
        self.title = "CHAT_ADD_FRIENDS".localized
        self.navigationItem.rightBarButtonItem = self.nextButton
    }
    
    // MARK: - User Actions
    
    @objc private func nextTapped() {
        let nameGroupVC = NameGroupViewController()
        nameGroupVC.selectedUsers = self.selectedUsers
        self.navigationController?.pushViewController(nameGroupVC, animated: true)
    }
}
