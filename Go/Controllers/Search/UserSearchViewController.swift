//
//  UserSearchViewController.swift
//  Go
//
//  Created by Lucky on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class UserSearchViewController: SHOTableViewController, SearchSegmentController, SHORefreshable, SHOPaginatable {
    
    var segmentTitle: String = "PEOPLE_SEARCH".localized
    var lastSearchedTerm: String?
    
    private lazy var friendManager = FriendshipManager(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControlDelegate = self
    }
    
    func loadResults(for term: String? = nil) {
        self.offset = 0
        self.fetchResults(for: term)
    }
    
    func loadData() {
        self.fetchResults(for: self.lastSearchedTerm)
    }
    
    func fetchResults(for term: String?) {
        SHOAPIClient.shared.users(forTerm: term, from: self.offset, to: self.limit) { (object, error, code) in
            self.sharedCompletionHandler(object, error)
        }
    }
    
}

//MARK: Tableview datasource

extension UserSearchViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FriendableUserTableViewCell = FriendableUserTableViewCell.reusableCell(from: tableView)
        if let user = user(at: indexPath) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let user = user(at: indexPath) {
            let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func user(at indexPath: IndexPath) -> UserModel? {
        return item(at: indexPath) as UserModel?
    }

}
