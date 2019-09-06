//
//  MapViewController.swift
//  Go
//
//  Created by Lucky on 17/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import GoogleMaps

typealias MapDataRequestClosure = ([EventModel]?, Error?) -> Void

protocol MapDataProvider {
    func getMapItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping MapDataRequestClosure)
}

fileprivate let CollectionViewSelectedCellInitialIndex = -1
fileprivate let MinimumCollectionViewHeight: CGFloat = 175.0

class MapViewController: SHOViewController, Filterable {
    
    //MARK: - Properties
    
    private var selectedCellIndex: NSInteger = CollectionViewSelectedCellInitialIndex

    private let dataProvider: MapDataProvider
    var request = FeedDataRequestModel() {
        didSet {
            self.loadData()
        }
    }
    
    private var items: [EventModel] = []
    private var coordinates = [GMSMarker]()
   
    private lazy var optionsManager = OptionsAlertManager(for: self)
    private let locationManager = SHOLocationManager.shared
    
    var filters: [String] = [] {
        didSet {
            self.request.tags = filters
            self.loadData()
        }
    }
    
    private var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                self.zoomMap(to: location)
            }
        }
    }
    
    var isEmptyState: Bool {
        return self.items.count == 0
    }
    
    let mapView: GMSMapView = {
        let map = GMSMapView(frame: .zero)
        map.settings.tiltGestures = false
        map.isIndoorEnabled = false
        return map
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(EventMapCollectionViewCell.self,
                                forCellWithReuseIdentifier: EventMapCollectionViewCell.reuseIdentifier)
        
        collectionView.register(EmptyStateCollectionViewCell.self,
                                forCellWithReuseIdentifier: EmptyStateCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    //MARK: - Init methods

    init(with dataProvider: MapDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        self.locationManager.startMonitoringLocation { [weak self] location, error in
            if let error = error {
                self?.showErrorAlertWith(message: error.localizedDescription)
            }
            self?.currentLocation = location
        }
    }
    
    deinit {
        self.mapView.delegate = nil
        self.locationManager.stopMonitoringLocation()
    }
    
    override func setup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.collectionView)
    }
    
    override func applyConstraints() {
        
        self.mapView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(mapView.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.3).priority(.high)
            make.height.greaterThanOrEqualTo(MinimumCollectionViewHeight).priority(.required)
            
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func zoomMap(to location: CLLocation) {
        let center: CLLocationCoordinate2D = location.coordinate
        
        let update = GMSCameraUpdate.setTarget(center, zoom: 12.0)
        self.mapView.animate(with: update)
    }
    
}

// MARK: - Networking

extension MapViewController {
    
    private func loadData() {
        
        self.dataProvider.getMapItemsWithRequest(self.request) { (events, error) in
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            
            // update collection data source
            if let items = events {
                self.items = items
            }
            
            // update map view annotations
            self.mapView.clear()
            self.coordinates.removeAll()
            self.items.forEach { event in
                if
                    let lat = event.latitude,
                    let lng = event.longitude {
                    
                    let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    let marker = GMSMarker(position: position)
                    marker.map = self.mapView
                    marker.icon = .mapPinInactive
                    
                    self.coordinates.append(marker)
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        let center = mapView.projection.coordinate(for: mapView.center)
        self.request.latitude = center.latitude
        self.request.longitude = center.longitude

        let region = mapView.projection.visibleRegion()
        let boundingBox = BoundingBoxRequestModel(top: region.farRight.latitude,
                                                  bottom: region.nearLeft.latitude,
                                                  left: region.nearLeft.longitude,
                                                  right: region.farRight.longitude)
        self.request.boundingBox = boundingBox
        
        self.loadData()
        self.selectedCellIndex = CollectionViewSelectedCellInitialIndex
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let index = self.coordinates.index(of: marker) else {
            return false
        }
        
        self.coordinates.forEach { marker in
            marker.icon = .mapPinInactive
        }
        marker.icon = .mapPinActive
        
        let indexPath = IndexPath(item: index, section: 0)
        let previousIndexPath = IndexPath(item: self.selectedCellIndex, section: 0)
        self.selectedCellIndex = index

        // Remove highlight from selected cell
        self.collectionView.cellForItem(at: previousIndexPath)?.isSelected = false

        // Highlight new selected cell
        self.collectionView.cellForItem(at: indexPath)?.isSelected = true

        // Scroll to new selected cell
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        return true
    }
}

// MARK: - UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.items.count > 0 {
            let event = self.items[indexPath.row]
            let controller = EventViewController(withEventModel: event)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.items.count
        return count > 0 ? count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.isEmptyState {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCollectionViewCell.reuseIdentifier,
                                                                for: indexPath) as? EmptyStateCollectionViewCell else {
                                                                    return UICollectionViewCell()
            }
            
            cell.imageview.image = UIImage.emptyState
            
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventMapCollectionViewCell.reuseIdentifier,
                                                                for: indexPath) as? EventMapCollectionViewCell else {
                                                                    return UICollectionViewCell()
            }
            
            let item = self.items[indexPath.row]
            cell.configureCell(with: item)
            cell.isSelected = (indexPath.row == self.selectedCellIndex)
            cell.delegate = self
            
            return cell
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isEmptyState {
            return CGSize(width: self.view.frame.width, height: self.collectionView.frame.height)
        }
        
        return CGSize(width: self.view.frame.width / 1.5, height: self.collectionView.frame.height)
    }
    
}

// MARK: - MapCollectionViewCellDelegate

extension MapViewController: MapEventCollectionViewCellDelegate {
    
    func didSelectUser(_ user: UserModel) {
        let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapOptions(for event: EventModel) {
        self.optionsManager.showOptions(forEvent: event) { [unowned self] in
            self.loadData()
        }
    }
    
}
