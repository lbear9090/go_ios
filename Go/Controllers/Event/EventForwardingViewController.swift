//
//  EventForwardingViewController.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class EventForwardingViewController: SelectFriendsViewController {
    
    private let eventId: Int64
    
    override var selectedUsers: [UserModel] {
        didSet {
            self.shareButton.isEnabled = selectedUsers.count > 0
        }
    }
    
    private lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "EVENT_FORWARDING_FORWARD".localized,
                                     style: .plain,
                                     target: self,
                                     action: #selector(shareTapped))
        button.tintColor = .green
        button.isEnabled = false
        return button
    }()
    
    private var successAlert: UIAlertController {
        let okAction = UIViewController.okAction { alert in
            self.navigationController?.popViewController(animated: true)
        }
        let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                               message: "EVENT_FORWARDING_SUCCESS_MSG".localized,
                                               actions: [okAction])
        return alert
    }
    
    //MARK: - Initializers
    
    init(eventId: Int64) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View callbacks
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "EVENT_FORWARDING_TITLE".localized
        self.navigationItem.rightBarButtonItem = self.shareButton
    }
    
    //MARK: - Networking
    
    override func loadSearchResults() {
        SHOAPIClient.shared.getFriends(withSearchTerm: self.searchString,
                                       forwarding: self.eventId,
                                       limit: self.limit,
                                       offset: self.offset) { object, error, code in
                                        self.sharedCompletionHandler(object, error)
        }
    }
    
    //MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let userCell = cell as? UserTableViewCell,
            let user: UserModel = item(at: indexPath) {
            userCell.invitedIconImageView.isHidden = !user.forwarded
        }
        return cell
    }
    
    //MARK: - User interaction
    
    @objc private func shareTapped() {
        self.showSpinner()
        
        let userIds: [Int64] = self.selectedUsers.map { $0.userId }
        SHOAPIClient.shared.forwardEvent(withId: self.eventId, toUsers: userIds) { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.present(self.successAlert, animated: true)
            }
        }
    }
    
}
