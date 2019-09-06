//
//  MapViewController.swift
//  Go
//
//  Created by Lucky on 17/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = .mapPinInactive
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            self.image = isSelected ? .mapPinActive : .mapPinInactive
        }
    }
    
}
