//
//  FeedDataRequestModel.swift
//  Go
//
//  Created by Lucky on 16/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal
import MapKit

public enum ContributionKey: String, PickerValue {
    case all
    case contribution
    case free
    
    public var pickerValue: String {
        return self.rawValue.capitalized
    }
    
    public static let contributionOptions: [ContributionKey] = [.all, .contribution, .free]
}

struct FeedDataRequestModel: Marshaling {
        
    var limit: Int = 20
    var offset: Int = 0
    var latitude: Double?
    var longitude: Double?
    var boundingBox: BoundingBoxRequestModel?
    var tags: [String]?
    var startAt: TimeInterval?
    var endAt: TimeInterval?
    var contribution: ContributionKey = .all
    
    func marshaled() -> [String: Any] {
        var dict = [String: Any]()
        
        if let lat = self.latitude,
            let lng = self.longitude {
            let locationDict = ["latitude": lat,
                                "longitude": lng]
            dict["location"] = locationDict
        }
        
        var filtersDict: [String: Any] = [:]
        filtersDict["tags"] = tags
        filtersDict["start_at"] = startAt
        filtersDict["end_at"] = endAt
        filtersDict["contribution_type"] = contribution.rawValue
        
        dict["filters"] = filtersDict
        
        
        
        dict[APIKeys.boundingBox] = self.boundingBox?.marshaled()
        dict[APIKeys.limit] = self.limit
        dict[APIKeys.offset] = self.offset
        
        return dict
    }

}

struct BoundingBoxRequestModel: Marshaling {
    var top: Double?
    var bottom: Double?
    var left: Double?
    var right: Double?
    
    var lonDelta: Double? {
        guard
            let right = self.right,
            let left = self.left else {
                return nil
        }
        return right - left
    }
    
    var latDelta: Double? {
        guard
            let bottom = self.bottom,
            let top = self.top else {
                return nil
        }
        return bottom - top
    }
    
    func marshaled() -> [String: Any] {
        var box = [String: Any]()
        
        box[APIKeys.top] = self.top
        box[APIKeys.bottom] = self.bottom
        box[APIKeys.left] = self.left
        box[APIKeys.right] = self.right
        
        return box
    }
}

extension BoundingBoxRequestModel {
    
    init(withMapRect rect: MKMapRect) {
        let neMapPoint = MKMapPoint(x: MKMapRectGetMaxX(rect), y: rect.origin.y)
        let swMapPoint = MKMapPoint(x: rect.origin.x, y: MKMapRectGetMaxY(rect))
        
        let topRight = MKCoordinateForMapPoint(neMapPoint)
        let bottomLeft = MKCoordinateForMapPoint(swMapPoint)
        
        self.bottom = bottomLeft.latitude
        self.left = bottomLeft.longitude
        self.right = topRight.longitude
        self.top = topRight.latitude
    }
    
}
