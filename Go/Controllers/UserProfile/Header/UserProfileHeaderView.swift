//
//  UserProfileHeaderView.swift
//  Go
//
//  Created by Lucky on 27/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class UserProfileHeaderView: CurrentUserProfileHeaderView {

    lazy var friendButton: FriendButton = {
        let button = FriendButton(type: .custom)
        return button
    }()
    
    lazy var mutualFriendsCountLabel: UILabel = {
        let config = LabelConfig(textFont: Font.bold.withSize(.small),
                                 textAlignment: .right,
                                 textColor: .green)
        let label: UILabel = UILabel(with: config)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(friendLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapRecognizer)
        
        return label
    }()

    override func setup() {
        super.setup()
        self.topStackView.insertArrangedSubview(self.friendButton, at: 0)
        self.topStackView.addArrangedSubview(self.mutualFriendsCountLabel)
        self.topStackView.removeArrangedSubview(self.friendsImageView)
        self.friendsImageView.removeFromSuperview()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.friendButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 36.0, height: 36.0))
        }
    }

    override func populate(with user: UserModel) {
        super.populate(with: user)
    
        self.friendButton.configureForUser(user)
    
        if  let mutualFriendCount = user.mutualFriendCount {
            self.mutualFriendsCountLabel.text = "\(mutualFriendCount) Mutual Friends"
        }
    }
}
