//
//  CurrencyModel.swift
//  Go
//
//  Created by Lucky on 21/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class CurrencyModel: Unmarshaling, Codable {
    
    var id: String
    var name: String
    var symbol: String
    var isoCode: String
    var isoNumeric: String
    
    required init(object: MarshaledObject) throws {
        id =            try object <| "id"
        name =          try object <| "name"
        symbol =        try object <| "symbol"
        isoCode =       try object <| "iso_code"
        isoNumeric =    try object <| "iso_numeric"
    }
    
}

class CurrencyAmountModel: Unmarshaling, Codable {
    var cents: Int
    var currency: CurrencyModel
    
    required init(object: MarshaledObject) throws {
        cents =     try object <| "cents"
        currency =  try object <| "currency"
    }
}
