//
//  BusinessDetailsModel.swift
//  Go
//
//  Created by Lucky on 14/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class BusinessDetailsModel: Unmarshaling, Codable {
    
    var id: Int64?
    var name: String?
    var taxId: String?
    var address: AddressModel = AddressModel()
    
    init() {}
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        name =      try object <| "name"
        taxId =     try object <| "tax_id"
        address =   try object <| "address"
    }

}
