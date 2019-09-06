//
//  LocationPickerViewController.swift
//  Go
//
//  Created by Lucky on 30/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import GoogleMaps

protocol LocationPickerViewControllerDelegate {
    func didSelectLocation(withCoordinate coordinate: CLLocationCoordinate2D, displayName: String)
}

class LocationPickerViewController: SHOViewController {
    
    // MARK: - Properties
    
    var delegate: LocationPickerViewControllerDelegate?
    var locationDisplayName: String?
    var settingMapToSelectedResultLocation = false
    
    private let mapView: GMSMapView = {
        let map = GMSMapView(frame: .zero)
        map.isIndoorEnabled = false
        map.settings.tiltGestures = false
        map.settings.myLocationButton = true
        return map
    }()
    
    private let locationManager = SHOLocationManager.shared
    private var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                self.zoomMap(to: location.coordinate)
            }
        }
    }
    
    private let markerImageView = UIImageView(image: .selectLocation)
    
    private let descriptionLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = Font.semibold.withSize(.extraLarge)
        label.textColor = .darkText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var searchController: UISearchController = {
        let resultsController = LocationPickerResultsViewController(withDelegate: self)
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        
        let searchBar = searchController.searchBar
        searchBar.tintColor = .green
        searchBar.barTintColor = .black
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = resultsController
        
        return searchController
    }()
    
    private lazy var buttonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "EVENT_LOCATION_SELECT".localized.uppercased()
        view.delegate = self
        return view
    }()
    
    convenience init(descriptionText: String) {
        self.init()
        self.descriptionLabel.text = descriptionText
    }
    
    // MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBar()
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager.startMonitoringLocation { [weak self] location, error in
            if let error = error {
                self?.showErrorAlertWith(message: error.localizedDescription)
            }
            self?.currentLocation = location
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopMonitoringLocation()
    }
    
    private func setupSearchBar() {
        self.definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = self.searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        
        } else {
            navigationItem.titleView = self.searchController.searchBar
            self.searchController.hidesNavigationBarDuringPresentation = false
        }
    }
    
    override func setup() {
        self.view.addSubview(self.descriptionLabel)
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.buttonView)
        
        self.mapView.addSubview(self.markerImageView)
    }
    
    override func applyConstraints() {
        self.descriptionLabel.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
            } else {
                make.top.equalToSuperview().inset(10)
            }
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(self.mapView.snp.top).offset(-10)
        }
        
        self.mapView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        
        self.markerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            let offset = self.markerImageView.bounds.height / 2
            make.centerY.equalToSuperview().offset(-offset)
        }
        
        self.buttonView.snp.makeConstraints { make in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(self.mapView.snp.bottom)
        }
    }
    
    // MARK: - Networking
    
    private func getAddress(for coordinate: CLLocationCoordinate2D) {
        self.showSpinner()
        SHOAPIClient.shared.address(forLatitude: coordinate.latitude,
                                    longitude: coordinate.longitude) { object, error, code in
                                        self.dismissSpinner()
                                        
                                        if let error = error {
                                            self.showErrorAlertWith(message: error.localizedDescription)
                                        
                                        } else if let address = object as? AddressSearchResultModel {
                                            self.delegate?.didSelectLocation(withCoordinate: coordinate,
                                                                             displayName: address.fullAddress)
                                            self.navigationController?.popViewController(animated: true)
                                        }
        }
    }
    
    // MARK: - Helpers

    private func zoomMap(to coordinate: CLLocationCoordinate2D) {
        let update = GMSCameraUpdate.setTarget(coordinate, zoom: 12.0)
        self.mapView.animate(with: update)
    }
}

// MARK: - Location results delegate

extension LocationPickerViewController: LocationSearchResultsControllerDelegate {
    
    func didSelectLocationResult(_ locationResult: LocationResultModel) {
        self.searchController.dismissModal()
        self.searchController.searchBar.text = nil
        
        self.zoomMap(to: CLLocationCoordinate2DMake(locationResult.latitude, locationResult.longitude))
        self.settingMapToSelectedResultLocation = true
        self.locationDisplayName = locationResult.name
    }
    
}

// MARK: - ButtonView delegate

extension LocationPickerViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        let centerCoordinate = self.mapView.camera.target
        
        if let name = self.locationDisplayName {
            self.delegate?.didSelectLocation(withCoordinate: centerCoordinate,
                                             displayName: name)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.getAddress(for: centerCoordinate)
        }
    }
    
}

extension LocationPickerViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !self.settingMapToSelectedResultLocation {
            self.locationDisplayName = nil
        }
        self.settingMapToSelectedResultLocation = false
    }
    
}
