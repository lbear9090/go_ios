//
//  TimelineItemModel.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import IGListKit
import Marshal

class TimelineModel: Unmarshaling, Codable {
    
    var id: Int64
    var user: UserModel
    var mediaItems: [MediaModel]
    var liked: Bool
    var likeCount: Int
    var commentCount: Int
    var comments: [CommentModel]
    var associatedEventId: Int64
    var associatedEventTitle: String
    var feedContext: FeedItemContextModel?
        
    required init(object: MarshaledObject) throws {
        id =                    try object <| "id"
        user =                  try object <| "user"
        mediaItems =            try object <| "media_items"
        liked =                 try object <| "liked"
        likeCount =             try object <| "number_of_likes"
        commentCount =          try object <| "number_of_comments"
        comments =              (try? object <| "comments") ?? []
        associatedEventId =     try object <| "event.id"
        associatedEventTitle =  try object <| "event.title"
    }

}

extension TimelineModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let timelineItem = object as? TimelineModel else {
            return false
        }
        return (timelineItem.id == self.id && timelineItem.commentCount == self.commentCount)
    }
}
