//
//  LocationPickerResultsViewController.swift
//  Go
//
//  Created by Lucky on 22/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

protocol LocationSearchResultsControllerDelegate: class {
    func didSelectLocationResult(_ locationResult: LocationResultModel)
}

class LocationPickerResultsViewController: SHOTableViewController {
    
    public weak var delegate: LocationSearchResultsControllerDelegate?
    
    private var searchTimer: Timer?
    private var isSearching = false
    private var searchString: String?
    private let locationManager = SHOLocationManager.shared
    private lazy var currentLocation: CLLocation? = locationManager.lastLocation
    
    convenience init(withDelegate delegate: LocationSearchResultsControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.startMonitoringLocation { (location, error) in
            self.currentLocation = location
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopMonitoringLocation()
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.backgroundColor = .clear
    }
    
    // MARK: - Networking
    
    private func searchWithTerm(_ term: String?) {
        let coordinate = self.currentLocation?.coordinate
        SHOAPIClient.shared.locations(for: term,
                                      latitude: coordinate?.latitude,
                                      longitude: coordinate?.longitude) { (object, error, code) in
            self.sharedCompletionHandler(object, error)
        }
    }
    
    override var emptyStateView: UIView? {
        return nil
    }
     
}

// MARK: - Tableview datasource

extension LocationPickerResultsViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = SearchTableViewCell.reusableCell(from: tableView)
        cell.leftSeparatorMargin = 0
        cell.imageView?.image = .searchLocation
        
        if let locationResult: LocationResultModel = item(at: indexPath) {
            cell.titleLabel.text = locationResult.name
            cell.detailLabel.text = locationResult.address
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedResult: LocationResultModel = item(at: indexPath) {
            self.delegate?.didSelectLocationResult(selectedResult)
        }
    }
    
}
    
// MARK: - UISearchResultsUpdating

extension LocationPickerResultsViewController: UISearchResultsUpdating {
    
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
        self.searchWithTerm(self.searchString)
    }
}

// MARK: - UISearchBarDelegate

extension LocationPickerResultsViewController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(true, animated: true)
            return
        }
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(false, animated: true)
            return
        }
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        self.searchString = nil
        self.items?.removeAll()
        self.tableView.reloadData()
    }
    
}
