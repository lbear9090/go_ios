//
//  CountryModel.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class CountryModel: Unmarshaling, Codable {
    
    var name: String
    var region: String
    var currency: CurrencyModel
    var emojiFlag: String
    var internationalPrefix: String
    var countryCode: String
    var alpha2: String
    var alpha3: String
    var euMember: Bool
    var northeastCoor: CoordinateModel
    var southwestCoor: CoordinateModel
    
    required init(object: MarshaledObject) throws {
        name =                  try object <| "name"
        region =                try object <| "region"
        currency =              try object <| "currency"
        emojiFlag =             try object <| "emoji_flag"
        internationalPrefix =   try object <| "international_prefix"
        countryCode =           try object <| "country_code"
        alpha2 =                try object <| "alpha2"
        alpha3 =                try object <| "alpha3"
        euMember =              try object <| "eu_member"
        northeastCoor =         try object <| "geometry.northeast"
        southwestCoor =         try object <| "geometry.southwest"
    }
    
}

extension CountryModel: PickerValue {
    
    var pickerValue: String {
        return self.name
    }
    
}

class CoordinateModel: Unmarshaling, Codable {
    
    var lat: Double
    var lng: Double
    
    required init(object: MarshaledObject) throws {
        lat = try object <| "lat"
        lng = try object <| "lng"
    }
}
