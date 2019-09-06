//
//  SearchSegmentedControlViewController.swift
//  Go
//
//  Created by Lucky on 24/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol SearchSegmentController: SegmentController {
    var lastSearchedTerm: String? { set get }
    func loadResults(for term: String?)
}

class SearchSegmentedControlViewController: SegmentedControlViewController {
    
    private lazy var searchManger = SearchControllerManager(with: self)
    
    init(with controllers: [SearchSegmentController]) {
        super.init(with: controllers)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchManger.addSearchController(to: self)
    }
    
    // MARK: - UnderlineSegmentedControlDelegate

    override func underlineSegmentedControlDidChange(_ segmentedControl: UnderlineSegmentedControl) {
        super.underlineSegmentedControlDidChange(segmentedControl)
        
        let persistedTerm = (self.activeController as? SearchSegmentController)?.lastSearchedTerm
        self.searchManger.searchController.searchBar.text = persistedTerm
    }
    
    // MARK: - Static inits
    
    static func searchConfiguration() -> SearchSegmentedControlViewController {
        return SearchSegmentedControlViewController(with: [TagSearchViewController(),
                                                           PlacesSearchViewController()])
    }
    
    static func friendsConfiguration(for userId: Int64) -> SearchSegmentedControlViewController {
        return SearchSegmentedControlViewController(with: [UserFriendsViewController(showing: .all, for: userId),
                                                           UserFriendsViewController(showing: .mutual, for: userId)])

    }
    
    static func findFriendsConfiguration() -> SearchSegmentedControlViewController {
        return SearchSegmentedControlViewController(with: [UserSearchViewController(),
                                                           ContactsFriendsViewController(),
                                                           FindFBFriendsViewController()])
    }
    
}

// MARK: - SearchControllerManagerDelegate

extension SearchSegmentedControlViewController: SearchControllerManagerDelegate {
    
    func searchWithTerm(_ term: String?) {
        guard let controller = self.activeController as? SearchSegmentController else {
            fatalError("Child controllers must adopt SearchSegmentController protocol")
        }
        controller.loadResults(for: term)
    }
    
    func searchCancelled() {
        guard let controller = self.activeController as? SearchSegmentController else {
            fatalError("Child controllers must adopt SearchSegmentController protocol")
        }
        controller.loadResults(for: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let controller = self.activeController as? SearchSegmentController else {
            fatalError("Child controllers must adopt SearchSegmentController protocol")
        }
        controller.lastSearchedTerm = searchText
    }
    
}

