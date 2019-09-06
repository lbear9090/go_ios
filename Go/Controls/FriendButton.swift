//
//  FriendButton.swift
//  Go
//
//  Created by Lucky on 23/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class FriendButton: UIButton {
    
    var user: UserModel?
    
    func configureForUser(_ user: UserModel) {
        self.user = user
        let image: UIImage
        
        if user.isFriend {
            image = .friendsIcon
        } else if user.isRequestedFriend {
            image = .pendingFriendsIcon
        } else {
            image = .findFriends
        }
        
        self.setBackgroundImage(image, for: UIControlState())
    }
    
    func setManager(_ manager: FriendshipManager) {
        self.addTarget(manager, action: #selector(FriendshipManager.didTapFriendButton), for: .touchUpInside)
    }
    
}
