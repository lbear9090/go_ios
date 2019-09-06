//
//  SHOLocationManager.swift
//  Go
//
//  Created by Lucky on 06/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import CoreLocation

public typealias LocationManagerCompletion = (_ location: CLLocation?, _ error: Error?) -> Void

public enum LocationErrorCode: Int {
    case locationPermissionsDenied = 1001
}

public struct RegionMonitoringNotificationKey {
    public static let SHODidEnterRegionNotification: String = "SHODidEnterRegionNotification"
    public static let SHODidExitRegionNotification: String = "SHODidExitRegionNotification"
}

public class SHOLocationManager: NSObject {
    
    public static let errorDomain: String = "com.error.location"
    
    public static let shared = SHOLocationManager()
    private override init() {}
    
    public var LocationManagerAccuracy: CLLocationAccuracy = 100.0
    public var LocationManagerDistanceThreshold: CLLocationDistance = 100.0
    private var storedCompletion: LocationManagerCompletion?
    public var lastLocation: CLLocation?
    
    public var requestAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    
    public var isAuthorized: Bool {
        return (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == .authorizedAlways)
    }

    public let manager = CLLocationManager()
    
    public func startMonitoringLocation(withCompletion completion: @escaping LocationManagerCompletion) {
        self.storedCompletion = completion
        manager.delegate = self
        manager.desiredAccuracy = LocationManagerAccuracy
        manager.distanceFilter = LocationManagerDistanceThreshold
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            self.manager.startUpdatingLocation()
        }
        
        if self.requestAuthorizationStatus == .authorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    public func stopMonitoringLocation() {
        manager.stopUpdatingLocation()
        self.storedCompletion = nil
    }
    
    private let permissionDeniedError: NSError = {
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Required permissions were not granted", comment: "")]
        var error = NSError(domain: errorDomain,
                            code: LocationErrorCode.locationPermissionsDenied.rawValue,
                            userInfo: userInfo)
        return error
    }()
}

//MARK: - Location Manager Delegate

extension SHOLocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.manager.startUpdatingLocation()
        case .restricted, .denied:
            self.storedCompletion?(nil, permissionDeniedError)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.first
        self.storedCompletion?(self.lastLocation, nil)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.storedCompletion?(nil, error)
    }
}

// MARK: - Region Monitoring

extension SHOLocationManager {
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            NotificationCenter.default.post(name: NSNotification.Name(RegionMonitoringNotificationKey.SHODidEnterRegionNotification),
                                            object: region)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NotificationCenter.default.post(name: NSNotification.Name(RegionMonitoringNotificationKey.SHODidExitRegionNotification),
                                        object: region)
    }
}
