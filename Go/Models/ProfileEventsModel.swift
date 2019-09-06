//
//  ProfileEventsModel.swift
//  Go
//
//  Created by Lucky on 06/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class ProfileEventsModel: Unmarshaling {
    
    var meta: ProfileEventsMetaModel
    var events: [EventModel]
    
    required init(object: MarshaledObject) throws {
        meta =      try object <| "meta"
        events =    (try? object <| "events") ?? []
    }
}

class ProfileEventsMetaModel: Unmarshaling {
    var eventCount: Int
    var attendingFriendsCount: Int
    var attendingFriends: [UserModel]
    
    required init(object: MarshaledObject) throws {
        eventCount =            try object <| "count"
        attendingFriendsCount = try object <| "mutual_user_count"
        attendingFriends =      try object <| "mutual_users"
    }
}
