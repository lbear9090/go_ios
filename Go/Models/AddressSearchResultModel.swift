//
//  AddressSearchResultModel.swift
//  Go
//
//  Created by Lucky on 07/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class AddressSearchResultModel: Unmarshaling {
    var fullAddress: String
    var street: String
    var state: String
    var postalCode: String
    var city: String
    var country: String
    
    required init(object: MarshaledObject) throws {
        fullAddress =   try object <| "address"
        street =        try object <| "street"
        state =         try object <| "state"
        postalCode =    try object <| "postal_code"
        city =          try object <| "city"
        country =       try object <| "country"
    }
}
