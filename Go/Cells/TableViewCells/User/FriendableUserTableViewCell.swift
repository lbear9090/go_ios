//
//  FriendableUserTableViewCell.swift
//  Go
//
//  Created by Lucky on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class FriendableUserTableViewCell: UserTableViewCell {
    
    lazy var friendButton: FriendButton = {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let button = FriendButton(frame: frame)
        return button
    }()
    
    lazy var currentUserId: Int = {
        return UserDefaults.standard.integer(forKey: UserDefaultKey.currentUserId)
    }()
    
    override func setup() {
        super.setup()
        self.accessoryView = self.friendButton
    }
    
    //MARK: - Configuration
    
    override func populate(with user: UserModel) {
        super.populate(with: user)
        self.friendButton.configureForUser(user)
        self.friendButton.isHidden = (self.currentUserId == user.userId)
    }

}
