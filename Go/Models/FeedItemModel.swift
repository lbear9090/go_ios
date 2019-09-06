//
//  FeedItemModel.swift
//  Go
//
//  Created by Lucky on 16/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal
import IGListKit

enum FeedItemType: String, Codable {
    case event
    case timeline = "event_timeline_item"
}

class FeedItemModel: Unmarshaling, Codable {
    
    var id: Int64
    var context: FeedItemContextModel?
    var type: FeedItemType
    var event: EventModel?
    var timelineItem: TimelineModel?
    var updatedAt: TimeInterval

    required init(object: MarshaledObject) throws {
        id =            try object <| "id"
        context =       try object <| "context"
        type =          try object <| "type"
        event =         try object <| "event"
        timelineItem =  try object <| "media"
        updatedAt =     (try? object <| "updated_at") ?? 0
    }
    
}

extension FeedItemModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let feedItem = object as? FeedItemModel else {
            return false
        }
        return (feedItem.id == self.id &&
                feedItem.updatedAt == self.updatedAt &&
                feedItem.timelineItem?.commentCount == self.timelineItem?.commentCount &&
                feedItem.event?.updatedAt == self.event?.updatedAt &&
                feedItem.event?.contribution?.type.slug == self.event?.contribution?.type.slug)
    }
}

class FeedItemContextModel: Unmarshaling, Codable {
    
    var id: Int64
    var message: ContextMessageModel
    var actor: UserModel
    var actorType: String
    var updatedAt: TimeInterval
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        message =   try object <| "message"
        actor =     try object <| "actor"
        actorType = try object <| "actor_type"
        updatedAt = try object <| "updated_at"
    }
    
}

class ContextMessageModel: Unmarshaling, Codable {
    
    var actor: String
    var action: String
    var full: String
    
    required init(object: MarshaledObject) throws {
        actor =     try object <| "actor"
        action =    try object <| "action"
        full =      try object <| "display"
    }
    
}
