//
//  LocationResultsMapViewController.swift
//  Go
//
//  Created by Lucky on 04/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import CoreLocation

class LocationResultsMapViewController: MapViewController {
    
    let selectedLocation: CLLocation
    
    init(with locationResult: LocationResultModel, dataProvider: MapDataProvider) {
        selectedLocation = CLLocation(latitude: locationResult.latitude,
                                      longitude: locationResult.longitude)
        super.init(with: dataProvider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.mapView.delegate = self
        self.zoomMap(to: selectedLocation)
    }
    
}
