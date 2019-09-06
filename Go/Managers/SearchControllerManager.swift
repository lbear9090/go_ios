//
//  SearchControllerManager.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol SearchControllerManagerDelegate: UISearchBarDelegate {
    func searchWithTerm(_ term: String?)
    func searchCancelled()
}

class SearchControllerManager: NSObject {
    
    weak var delegate: SearchControllerManagerDelegate?
    
    fileprivate var searchTimer: Timer?
    fileprivate var isSearching = false
    fileprivate var searchString: String?
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        let searchBar = searchController.searchBar
        searchBar.tintColor = .green
        searchBar.barTintColor = .black
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        
        return searchController
    }()
    
    init(with delegate: SearchControllerManagerDelegate) {
        self.delegate = delegate
    }
    
    public func addSearchController(to controller: UIViewController) {
        controller.definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            controller.navigationItem.searchController = self.searchController
            controller.navigationItem.hidesSearchBarWhenScrolling = false
            
        } else {
            controller.navigationItem.titleView = self.searchController.searchBar
            self.searchController.hidesNavigationBarDuringPresentation = false
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension SearchControllerManager: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let queryString = searchController.searchBar.text else {
            return
        }
        
        if let timer = self.searchTimer, timer.isValid {
            timer.invalidate()
        }
        
        if queryString.count > 1 {
            self.isSearching = true
            self.searchString = queryString
            self.searchTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                                    target: self,
                                                    selector: #selector(timerExpired),
                                                    userInfo: nil,
                                                    repeats: false)
        }
    }
    
    @objc func timerExpired() {
        guard let timer = self.searchTimer else {
            return
        }
        
        if timer.isValid {
            timer.invalidate()
        }
        
        self.searchTimer = nil
        delegate?.searchWithTerm(self.searchString)
    }
}

// MARK: - UISearchBarDelegate

extension SearchControllerManager: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarTextDidBeginEditing?(searchBar)
        
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(true, animated: true)
            return
        }
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarTextDidEndEditing?(searchBar)
        
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(false, animated: true)
            return
        }
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        self.searchString = nil
        
        delegate?.searchCancelled()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar?(searchBar, textDidChange: searchText)
    }
    
}
