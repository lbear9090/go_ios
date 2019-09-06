//
//  PaymentMethodModel.swift
//  Go
//
//  Created by Lucky on 09/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class PaymentMethodModel: Unmarshaling {
    
    var id: Int64
    var brand: String
    var country: String
    var cvcCheck: String
    var expiryMonth: Int
    var expiryYear: Int
    var lastFourDigits: String
    var defaultMethod: Bool

    required init(object: MarshaledObject) throws {
        id =                try object <| "id"
        brand =             try object <| "brand"
        country =           try object <| "country"
        cvcCheck =          try object <| "cvc_check"
        expiryMonth =       try object <| "exp_month"
        expiryYear =        try object <| "exp_year"
        lastFourDigits =    try object <| "last_four"
        defaultMethod =     (try? object <| "default") ?? false
    }
}
