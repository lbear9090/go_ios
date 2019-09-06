//
//  EventModel.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import IGListKit
import Marshal

class ConversationEventModel: Unmarshaling, Codable {
    
    var eventId: Int64
    var host: UserModel
    var title: String
    var updatedAt: TimeInterval
    var mediaItems: [MediaModel]?
    var conversationID: Int64

    required init(object: MarshaledObject) throws {
        eventId =                         try object <| "id"
        host =                            try object <| "user"
        title =                           try object <| "title"
        updatedAt =                       try object <| "updated_at"
        mediaItems =                      try? object <| "event_media_items"
        conversationID =                (try? object <| "conversation.id") ?? -1
    }
    
    func updateWith(event: EventModel) {
        self.eventId = event.eventId
        self.host = event.host
        self.title = event.title
        self.updatedAt = event.updatedAt
        self.mediaItems = event.mediaItems
        self.conversationID = event.conversationID
    }
}
