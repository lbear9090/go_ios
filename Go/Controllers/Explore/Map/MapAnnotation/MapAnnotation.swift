//
//  MapViewController.swift
//  Go
//
//  Created by Lucky on 17/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
