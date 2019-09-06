//
//  CurrentUserFriendsViewController.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class CurrentUserFriendsViewController: UserSearchViewController {

    private lazy var searchManger = SearchControllerManager(with: self)
    private var searchTerm: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchManger.addSearchController(to: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "USER_FRIENDS".localized
    }
    
    override func loadResults(for term: String?) {
        fatalError("Use loadData method instead")
    }
    
    override func loadData() {
        SHOAPIClient.shared.getFriends(withSearchTerm: self.searchTerm,
                                       limit: self.limit,
                                       offset: self.offset) { (object, error, code) in
                                        self.sharedCompletionHandler(object, error)
        }
    }
    
}

// MARK: - SearchControllerManagerDelegate

extension CurrentUserFriendsViewController: SearchControllerManagerDelegate {
    
    func searchWithTerm(_ term: String?) {
        self.offset = 0
        self.searchTerm = term
        self.refreshData()
    }
    
    func searchCancelled() {
        self.offset = 0
        self.searchTerm = nil
        self.refreshData()
    }
    
}
