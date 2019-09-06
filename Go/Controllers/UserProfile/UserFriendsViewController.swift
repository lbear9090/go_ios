//
//  UserFriendsViewController.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class UserFriendsViewController: UserSearchViewController {
    
    private let scope: FriendsRequestScope
    private var searchTerm: String?
    private let userId: Int64
    
    init(showing scope: FriendsRequestScope = .all, for userId: Int64) {
        self.scope = scope
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
        self.segmentTitle = scope.rawValue.capitalized
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshData()
    }
    
    override func loadResults(for term: String?) {
        self.offset = 0
        self.searchTerm = term
        self.refreshData()
    }

    override func loadData() {
        SHOAPIClient.shared.getFriends(.userWithId(self.userId), withSearchTerm: self.searchTerm,
                                       scope: self.scope,
                                       limit: self.limit,
                                       offset: self.offset) { (object, error, code) in
                                        self.dismissSpinner()
                                        self.sharedCompletionHandler(object, error)
        }
    }
}
