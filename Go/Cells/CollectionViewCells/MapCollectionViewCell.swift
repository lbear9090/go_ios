//
//  MapCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 28/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import MapKit

class MapCollectionViewCell: BaseCollectionViewCell {
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.isUserInteractionEnabled = false
        map.delegate = self
        return map
    }()
    
    override func setup() {
        self.contentView.addSubview(self.mapView)
    }
    
    override func applyConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func showLocation(_ location: LocationResultModel) {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
        self.mapView.setRegion(region, animated: false)
        
        let annotation = MapAnnotation(coordinate: coordinate)
        self.mapView.addAnnotation(annotation)
    }
    
}

extension MapCollectionViewCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MapAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.isSelected = true
        return annotationView
    }
}
