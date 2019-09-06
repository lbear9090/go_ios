//
//  NotificationModel.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

enum NotificationType: String, Codable {
    case general
    case friendRequest = "friend_request"
    case friendshipCreated = "friendship_created"
    case eventInvite = "event_invitation"
    case eventAttendee = "event_owner_attendee"
    case eventShare = "event_share"
    case fbEventsImport = "user_facebook_event_import"
    case timelineLike = "event_timeline_item_like"
    case timelineComment = "event_timeline_item_comment"
    case messageSent = "message_sent"
    case eventRequestOwner = "event_attendee_request_owner"
    case eventRequestResponse = "event_attendee_request_response"
    case eventCancelled = "event_cancelled"
    case upcomingEvent = "event_upcoming"
    
    var icon: UIImage {
        switch self {
        case .general, .fbEventsImport:
            return .notificationGeneric
        case .friendRequest, .friendshipCreated:
            return .notificationFriendRequest
        case .timelineLike:
            return .notificationTimeline
        case .timelineComment:
            return .notificationComment
        case .eventInvite, .eventRequestOwner, .messageSent:
            return .notificationMessage
        case .eventShare, .eventRequestResponse, .eventAttendee, .upcomingEvent, .eventCancelled:
            return .notificationInvitation
        }
    }
}

enum NotificationStatus: String, Codable {
    case sent = "sent"
    case read = "read"
}

class NotificationModel: Unmarshaling, Codable {
    var notificationId: Int64
    var message: String
    var status: NotificationStatus
    var createdAt: TimeInterval
    var type: NotificationType?
    var resources: NotificationResourcesModel?
    
    required init(object: MarshaledObject) throws {
        notificationId =    try object <| "id"
        status =            try object <| "status"
        message =           (try? object <| "message") ?? ""
        createdAt =         (try? object <| "created_at") ?? 0
        type =              try? object <| "notification_type"
        resources =         try? object <| "resources"
    }
}

class NotificationResourcesModel: Unmarshaling, Codable {
    var genericBundle: GenericNotificationBundle?
    var user: UserModel?
    var event: EventModel?
    var friendRequest: FriendRequestModel?
    var timelineItem: TimelineModel?
    var facebookEvent: FacebookEvent?
    var conversationID: Int64?
    var message: Message?
    var requestingAttendee: AttendeeModel?
    
    required init(object: MarshaledObject) throws {
        genericBundle =         try? object <| "general_notification"
        user =                  (try? object <| "user") ??
                                (try? object <| "event_share.user") ??
                                (try? object <| "event_attendee.user")
        event =                 (try? object <| "event") ??
                                (try? object <| "event_share.event")
        friendRequest =         try? object <| "friend_request"
        timelineItem =          try? object <| "event_timeline_item"
        facebookEvent =         try? object <| "user_facebook_event_import"
        conversationID =        try? object <| "conversation_id"
        message =               try? object <| "message"
        requestingAttendee =    try? object <| "event_attendee"
    }
}

class GenericNotificationBundle: Unmarshaling, Codable {
    var objectId: Int64
    var title: String
    var message: String
    var platform: NotificationPlatformModel
    
    required init(object: MarshaledObject) throws {
        objectId =  try object <| "id"
        title =     try object <| "title"
        message =   try object <| "message"
        platform =  try object <| "platform"
    }
}

class NotificationPlatformModel: Unmarshaling, Codable {
    var platformId: Int64
    var name: String
    var images: ImagesModel?
    
    required init(object: MarshaledObject) throws {
        platformId = try object <| "id"
        name =      (try? object <| "name") ?? ""
        images =    (try? object <| "images")
    }
}

class FacebookEvent: Unmarshaling, Codable {
    var message: String
    
    required init(object: MarshaledObject) throws {
        message = (try? object <| "message") ?? ""
    }
}
