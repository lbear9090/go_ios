//
//  Conversation.swift
//  Go
//
//  Created by Lucky on 06/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import MessageKit
import Kingfisher
import Marshal

class Conversation: Unmarshaling, Codable {
    var id: Int64
    var name: String
    var image: ImagesModel?
    var messages: [Message]
    var unread: Bool
    var unreadCount: Int
    var event: ConversationEventModel?
    var participants: [Participant]
    var participantCounts: Int
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var muted: Bool
    var owner: Bool
    
    required init(object: MarshaledObject) throws {
        id =                      try object <| "id"
        name =                  (try? object <| "meta_data.name") ?? ""
        image =                  try? object <| "meta_data.images"
        messages =              (try? object <| "messages") ?? []
        unread =                (try? object <| "unread") ?? false
        unreadCount =           (try? object <| "unread_count") ?? 0
        event =                 (try? object <| "event")
        participants =          (try? object <| "participants") ?? []
        participantCounts =     (try? object <| "participant_count") ?? 0
        createdAt =             (try? object <| "created_at") ?? Date().timeIntervalSince1970
        updatedAt =             (try? object <| "updated_at") ?? Date().timeIntervalSince1970
        muted =                 (try? object <| "muted") ?? false
        owner =                 (try? object <| "owner") ?? false
    }
}
