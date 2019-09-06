//
//  EventShareModel.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class EventShareModel: Unmarshaling {
    var shareId: Int64
    var event: EventModel
    var sharer: UserModel
    var sharedTo: [UserModel]
    
    required init(object: MarshaledObject) throws {
        shareId =   try object <| "id"
        event =     try object <| "event"
        sharer =    try object <| "user"
        sharedTo =  try object <| "users"
    }
}
