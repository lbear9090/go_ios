//
//  RegistrationModel.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class RegistrationModel: Unmarshaling {
    var user: UserModel?
    var token: AuthTokenModel?
    
    required init(object: MarshaledObject) throws {
        user =  try? object <| "user"
        token = try? object <| "token"
    }
}

class AvailabilityModel: Unmarshaling {
    var available: Bool
    
    required init(object: MarshaledObject) throws {
        available = (try? object <| "available") ?? true
    }
    
}
