//
//  FBEventImportModel.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class FBEventImportModel: Unmarshaling {
    var importing: Bool
    var message: String
    
    required init(object: MarshaledObject) throws {
        importing = try object <| "importing"
        message =   try object <| "message"
    }
}
