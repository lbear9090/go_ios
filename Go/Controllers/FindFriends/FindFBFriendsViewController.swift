//
//  FindFBFriendsViewController.swift
//  Go
//
//  Created by Lucky on 23/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FindFBFriendsViewController: SHOTableViewController, SearchSegmentController {
    
    var segmentTitle: String = "FIND_FRIENDS_FACEBOOK".localized
    var lastSearchedTerm: String?

    private lazy var friendManager = FriendshipManager(with: self)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let token = FBSDKAccessToken.current(),
            token.expirationDate.isInFuture,
            token.hasGranted(FBPermission.userFriends.rawValue) else {
                let backgroundView = CenteredButtonView(frame: self.tableView.bounds)
                backgroundView.button.setTitle("FIND_FRIENDS_CONNECT_FB".localized, for: .normal)
                backgroundView.button.setBackgroundColor(.fbBlue, forState: .normal)
                backgroundView.button.addTarget(self,
                                                action: #selector(requestFriendsPermission),
                                                for: .touchUpInside)
                self.tableView.backgroundView = backgroundView
                return
        }
        //Check anyway to catch edge cases
        self.requestFriendsPermission()
    }
    
    @objc private func requestFriendsPermission() {
        FBPermissionsManager.requestUserPermission(.userFriends, onController: self) { error in
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.tableView.backgroundView = nil
                self.loadResults(for: self.lastSearchedTerm)
            }
        }
    }
    
    // MARK: - Networking
    
    func loadResults(for term: String?) {
        self.showSpinner()
        SHOAPIClient.shared.getFBFriends(matching: term) { object, error, code in
            self.dismissSpinner()
            self.sharedCompletionHandler(object, error)
        }
    }
    
    // MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FriendableUserTableViewCell = FriendableUserTableViewCell.reusableCell(from: tableView)
        if let user: UserModel = item(at: indexPath) {
            cell.populate(with: user)
            cell.friendButton.setManager(self.friendManager)
            
            cell.attendingIconTappedHandler = { [unowned self] in
                let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
                controller.initialEventsType = .attending
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        return cell
    }
    
    //MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = SectionHeaderView()
        headerView.backgroundColor = .white
        
        headerView.leftLabel.font = Font.medium.withSize(.medium)
        headerView.leftLabel.textColor = .green
        headerView.leftLabel.text = "EXISTING_FRIENDS_HEADER".localized
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

}
