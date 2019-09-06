//
//  LocationResultModel.swift
//  Go
//
//  Created by Lucky on 22/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal
import IGListKit

class LocationResultModel: Unmarshaling {
    
    var id: String
    var name: String
    var address: String
    var countryName: String
    var latitude: Double
    var longitude: Double
    var annotationRadius: Int
    
    required init(object: MarshaledObject) throws {
        id =                try object <| "id"
        name =              try object <| "name"
        address =           try object <| "address"
        countryName =       try object <| "country"
        latitude =          try object <| "latitude"
        longitude =         try object <| "longitude"
        annotationRadius =  try object <| "annotation_radius"
    }
}

extension LocationResultModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let location = object as? LocationResultModel else {
            return false
        }
        return location.latitude == self.latitude && location.longitude == self.longitude
    }
    
}
