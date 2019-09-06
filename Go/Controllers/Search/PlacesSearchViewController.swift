//
//  PlacesSearchViewController.swift
//  Go
//
//  Created by Lucky on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import CoreLocation

class PlacesSearchViewController: SHOTableViewController, SearchSegmentController {
    
    var segmentTitle: String = "PLACES_SEARCH".localized
    var lastSearchedTerm: String?
    
    private let locationManager = SHOLocationManager.shared
    private var location: CLLocation? {
        didSet {
            if oldValue == nil && self.lastSearchedTerm == nil {
                self.loadResults(for: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.startMonitoringLocation { [weak self] (location, error) in
            self?.location = location
        }
        if lastSearchedTerm == nil {
            self.loadResults(for: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopMonitoringLocation()
    }

    func loadResults(for term: String?) {
        
        let latitude = self.location?.coordinate.latitude
        let longitude = self.location?.coordinate.longitude
        
        SHOAPIClient.shared.locations(for: term,
                                      latitude: latitude,
                                      longitude: longitude) { (object, error, code) in
            self.sharedCompletionHandler(object, error)
        }
    }
    
}

//MARK: Tableview datasource

extension PlacesSearchViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = SearchTableViewCell.reusableCell(from: tableView)
        cell.imageView?.image = .searchLocation

        if let location: LocationResultModel = item(at: indexPath) {
            cell.titleLabel.text = location.name
            cell.detailLabel.text = location.address
        }
        return cell
    }
    
}

//MARK: Tableview delegate

extension PlacesSearchViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let location: LocationResultModel = item(at: indexPath) {
            let dataProvider = LocationEventsDataProvider(withLocation: location)
            
            let feedController = FilterableFeedViewController(with: dataProvider)
            let mapController = LocationResultsMapViewController(with: location, dataProvider: dataProvider)
            let containerController = FeedMapContainerViewController(feedController: feedController,
                                                                     mapController: mapController,
                                                                     segmentTitle: "FRIENDS_TITLE".localized)
            containerController.addNavigationItemLogo()
            self.navigationController?.pushViewController(containerController, animated: true)
        }
    }
    
}
