//
//  InviteFBUserToEventViewController.swift
//  Go
//
//  Created by Lucky on 15/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class InviteFBUserToEventViewController: FindFBFriendsViewController {
    
    let eventId: Int64
    
    init(withEventId: Int64) {
        self.eventId = withEventId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Tableview datasource & delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let friendCell = cell as? FriendableUserTableViewCell,
            let user: UserModel = item(at: indexPath) {
            friendCell.invitedIconImageView.isHidden = !user.invited
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let user: UserModel = item(at: indexPath) {
            self.inviteUser(user, toEventWithId: self.eventId)
        }
    }
    
    //MARK: - Networking
    
    override func loadResults(for term: String? = nil) {
        self.showSpinner()
        SHOAPIClient.shared.getFBFriends(matching: term, withInvitedStateFor: self.eventId) { object, error, code in
            self.dismissSpinner()
            self.sharedCompletionHandler(object, error)
        }
    }
    
    private func inviteUser(_ user: UserModel, toEventWithId eventId: Int64) {
        self.showSpinner()
        SHOAPIClient.shared.inviteUser(user, toEventWithId: eventId) { (object, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let messageResponse = object as? ResponseMessageModel {
                let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                       message: messageResponse.message)
                
                let okAction = UIViewController.okAction(withHandler: { action in
                    self.self.loadResults()
                })
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
        }
    }

}
