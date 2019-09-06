//
//  BankAccountModel.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class BankAccountModel: Unmarshaling {
    
    var id: String
    var lastFour: String
    var bankName: String
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        lastFour =  try object <| "last_four"
        bankName =  try object <| "bank_name"
    }
}
