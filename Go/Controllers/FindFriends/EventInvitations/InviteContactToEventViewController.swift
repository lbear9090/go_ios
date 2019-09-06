//
//  InviteContactToEventViewController.swift
//  Go
//
//  Created by Lucky on 01/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class InviteContactToEventViewController: ContactsFriendsViewController {
    
    let eventID: Int64!
    
    init(with eventID: Int64) {
        self.eventID = eventID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var inviteLabelText: String {
        return "INVITE_FRIEND".localized
    }
    
    // MARK: - Network
    
    override func loadResults(for term: String?) {
        self.showSpinner()
        SHOAPIClient.shared.findFriends(from: self.requestContacts,
                                        matching: term,
                                        for: self.eventID) { (object, error, code) in
                                            self.dismissSpinner()
                                            if let error = error {
                                                self.showErrorAlertWith(message: error.localizedDescription)
                                            } else if let result = object as? ContactsFetchModel {
                                                self.returnedContacts = result.contacts
                                            } else {
                                                self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
                                            }
                                            self.tableView.reloadData()
        }
    }
    
    override func inviteContact(_ contact: ContactModel) {
        self.showSpinner()
        SHOAPIClient.shared.inviteContact(contact, toEventWithId: self.eventID) { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
                
            } else if let response = object as? ResponseMessageModel {
                self.loadResults(for: self.lastSearchedTerm)
                let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                       message: response.message)
                alert.addAction(UIViewController.okAction())
                self.present(alert, animated: true)
            }
        }
    }
}
