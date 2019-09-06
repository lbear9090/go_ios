//
//  CommentModel.swift
//  Go
//
//  Created by Lucky on 16/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class CommentModel: Unmarshaling, Codable {

    var id: Int64
    var user: UserModel
    var content: String
    var active: Bool
    var createdAt: TimeInterval
    var updatedAt: TimeInterval

    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        user =      try object <| "user"
        content =   try object <| "content"
        active =    try object <| "active"
        createdAt = try object <| "created_at"
        updatedAt = try object <| "updated_at"
    }
    
}
