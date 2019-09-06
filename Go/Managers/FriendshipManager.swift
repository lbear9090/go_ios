//
//  FriendshipManager.swift
//  Go
//
//  Created by Lucky on 23/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation

class FriendshipManager {
    
    private weak var controller: SHOViewController?
    private weak var button: FriendButton?
    
    init(with controller: SHOViewController) {
        self.controller = controller
    }
    
    @objc func didTapFriendButton(_ sender: FriendButton) {
        self.button = sender
        if let user = sender.user {
            if user.isFriend {
                self.showUnfriendAlert(for: user)
            } else if user.isRequestedFriend {
                self.showCancelRequestAlert(forUser: user)
            } else {
                self.createFriendRequest(for: user)
            }
        }
    }
    
    //MARK: - Create friend request
    
    func createFriendRequest(for user: UserModel) {
        self.controller?.showSpinner()
        SHOAPIClient.shared.createFriendRequest(forUserId: user.userId) { (object, error, code) in
            self.controller?.dismissSpinner()
            if let error = error {
                self.controller?.showErrorAlertWith(message: error.localizedDescription)
            } else if let request = object as? FriendRequestModel {
                user.isFriend = request.requestedUser.isFriend
                user.isRequestedFriend = request.requestedUser.isRequestedFriend
                user.friendRequestId = request.id
                self.button?.configureForUser(request.requestedUser)
            }
        }
    }

    //MARK: - Cancel friend request

    func showCancelRequestAlert(forUser user: UserModel) {
        
        let alertTitle = "DELETE_FRIEND_REQUEST_TITLE".localized
        
        let deleteRequestAction = UIViewController.deleteAction { alert in
            self.cancelRequest(toUser: user)
        }
        let cancelAction = UIViewController.cancelAction()
        
        let alert = UIViewController.alertWith(title: alertTitle,
                                               message: nil,
                                               actions: [deleteRequestAction, cancelAction])
        
        self.controller?.present(alert, animated: true)
    }
    
    func cancelRequest(toUser user: UserModel) {
        guard let requestId = user.friendRequestId else {
            self.controller?.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
            return
        }
        
        self.controller?.showSpinner()
        SHOAPIClient.shared.deleteFriendRequest(withId: requestId) { (object, error, code) in
            self.controller?.dismissSpinner()
            if let error = error {
                self.controller?.showErrorAlertWith(message: error.localizedDescription)
            } else {
                user.isFriend = false
                user.isRequestedFriend = false
                self.button?.configureForUser(user)
            }
        }
    }
    
    //MARK: - Remove friend
    
    func showUnfriendAlert(for user: UserModel) {
        let alertTitle = "UNFRIEND_ALERT_TITLE".localized
        let alertMessage = String(format: "UNFRIEND_ALERT_MSG".localized, user.displayName)
        
        let unfriendAction = UIViewController.yesAction { alert in
            self.unfriendUser(user)
        }
        let cancelAction = UIViewController.cancelAction()
        
        let alert = UIViewController.alertWith(title: alertTitle,
                                               message: alertMessage,
                                               actions: [unfriendAction, cancelAction])
        
        self.controller?.present(alert, animated: true)
    }
    
    func unfriendUser(_ user: UserModel) {
        self.controller?.showSpinner()
        SHOAPIClient.shared.removeFriend(withId: user.userId) { (object, error, code) in
            self.controller?.dismissSpinner()
            if let error = error {
                self.controller?.showErrorAlertWith(message: error.localizedDescription)
            } else {
                user.isFriend = false
                user.isRequestedFriend = false
                self.button?.configureForUser(user)
            }
        }
    }
    
}
