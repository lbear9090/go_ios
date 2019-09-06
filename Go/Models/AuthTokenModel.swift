//
//  AuthToken.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import Marshal

class AuthTokenModel: Unmarshaling {
    var accessToken: String
    var tokenType: String
    var scope: String
    var expiresIn: TimeInterval
    var createdAt: TimeInterval
    
    required init(object: MarshaledObject) throws {
        accessToken =   try object <| "access_token"
        tokenType =     try object <| "token_type"
        scope =         try object <| "scope"
        expiresIn =     try object <| "expires_in"
        createdAt =     try object <| "created_at"
    }
}

class AuthTokenWrapperModel: Unmarshaling {
    var authToken: AuthTokenModel
    var message: String?
    var merge: Bool
    
    required init(object: MarshaledObject) throws {
        authToken = try object <| "token"
        message =   try? object <| "message"
        merge =     (try? object <| "merge") ?? false
    }
}
