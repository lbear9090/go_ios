//
//  FriendRequestModel.swift
//  Go
//
//  Created by Lucky on 23/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class FriendRequestModel: Unmarshaling, Codable {

    var id: Int64
    var requestingUser: UserModel
    var requestedUser: UserModel
    
    required init(object: MarshaledObject) throws {
        id =                try object <| "id"
        requestingUser =    try object <| "user"
        requestedUser =     try object <| "friend"
    }
}
