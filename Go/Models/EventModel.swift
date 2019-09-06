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

class EventModel: Unmarshaling, Codable {
    
    var eventId: Int64
    var host: UserModel
    var title: String
    var description: String
    var time: TimeInterval
    var date: TimeInterval
    var eighteenPlus: Bool
    var reported: Bool
    var attendeeCount: Int
    var friendsAttendingCount: Int
    var latitude: Double?
    var longitude: Double?
    var categories: String?
    var bring: String?
    var address: String
    var country: CountryModel?
    var mediaItems: [MediaModel]
    var isPrivate: Bool
    var allowsForwarding: Bool
    var allowChat: Bool
    var showTimeline: Bool
    var active: Bool?
    var updatedAt: TimeInterval
    var contribution: EventContributionModel?
    var userAttendance: AttendeeModel?
    var attendees: [AttendeeModel]
    var invitedAllFriends: Bool
    var attendingFriends: [UserModel]
    var relatedEvents: [EventModel]
    var conversationID: Int64
    var isPublicByInvite: Bool
    var maximumAttendees: Int
    var eventTicketURL: String?
    var eventTicketOriginalURL: String?
    
    var feedContext: FeedItemContextModel?

    required init(object: MarshaledObject) throws {
        eventId =                         try object <| "id"
        host =                            try object <| "user"
        title =                           try object <| "title"
        description =                   (try? object <| "description") ?? ""
        time =                            try object <| "time"
        date =                            try object <| "date"
        eighteenPlus =                    try object <| "eighteen_plus"
        reported =                        try object <| "reported"
        attendeeCount =                 (try? object <| "attendee_count") ?? 0
        friendsAttendingCount =         (try? object <| "mutual_attendee_count") ?? 0
        latitude =                       try? object <| "location.latitude"
        longitude =                      try? object <| "location.longitude"
        categories =                      try object <| "categories"
        bring =                          try? object <| "bring"
        address =                         try object <| "address"
        country =                        try? object <| "country"
        mediaItems =                      try object <| "event_media_items"
        isPrivate =                       try object <| "private_event"
        allowsForwarding =                try object <| "event_forwarding"
        allowChat =                       try object <| "allow_chat"
        showTimeline =                    try object <| "show_timeline"
        active =                          try object <| "active"
        updatedAt =                       try object <| "updated_at"
        contribution =                   try? object <| "event_contribution_detail"
        userAttendance =                 try? object <| "attendance"
        attendees =                     (try? object <| "attendees") ?? []
        attendingFriends =              (try? object <| "mutual_attendees") ?? []
        invitedAllFriends =             (try? object <| "invite_all_friends") ?? false
        relatedEvents =                 (try? object <| "related_events") ?? []
        conversationID =                (try? object <| "conversation.id") ?? -1
        isPublicByInvite =                try object <| "attendance_acceptance_required"
        maximumAttendees =              (try? object <| "maximum_attendees") ?? InvalidDefaultValue
        eventTicketURL =                (try? object <| "event_ticket_detail.url")
        eventTicketOriginalURL =        (try? object <| "event_ticket_detail.original_url")
    }
    
    func updateWith(event: EventModel) {
        self.eventId = event.eventId
        self.host = event.host
        self.title = event.title
        self.description = event.description
        self.time = event.time
        self.date = event.date
        self.eighteenPlus = event.eighteenPlus
        self.reported = event.reported
        self.attendeeCount = event.attendeeCount
        self.friendsAttendingCount = event.friendsAttendingCount
        self.latitude = event.latitude
        self.longitude = event.longitude
        self.categories = event.categories
        self.bring = event.bring
        self.address = event.address
        self.country = event.country
        self.mediaItems = event.mediaItems
        self.isPrivate = event.isPrivate
        self.allowsForwarding = event.allowsForwarding
        self.allowChat = event.allowChat
        self.showTimeline = event.showTimeline
        self.active = event.active
        self.updatedAt = event.updatedAt
        self.contribution = event.contribution
        self.userAttendance = event.userAttendance
        self.attendees = event.attendees
        self.attendingFriends = event.attendingFriends
        self.invitedAllFriends = event.invitedAllFriends
        self.relatedEvents = event.relatedEvents
        self.conversationID = event.conversationID
        self.isPublicByInvite = event.isPublicByInvite
        self.maximumAttendees = event.maximumAttendees
        self.eventTicketURL = event.eventTicketURL
        self.eventTicketOriginalURL = event.eventTicketOriginalURL
    }
}

extension EventModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return eventId as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let event = object as? EventModel else {
            return false
        }
        return (
            event.eventId == self.eventId &&
            event.updatedAt == self.updatedAt &&
            event.userAttendance?.updatedAt == self.userAttendance?.updatedAt
        )
    }
}

class EventContributionModel: Unmarshaling, Codable {
    var id: Int64
    var type: ContributionType
    var amount: CurrencyAmountModel
    var reason: String?
    var optional: Bool
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        type =      try object <| "event_contribution_type"
        amount =    try object <| "amount"
        reason =    try? object <| "reason"
        optional =  try object <| "optional"
    }
    
}

class ContributionType: Unmarshaling, Codable {
    var id: Int64
    var name: String
    var slug: String
    var alertTitle: String
    var alertMsg: String
    var changeAmountTitle: String
    var changeAmountMsg: String
    
    required init(object: MarshaledObject) throws {
        id = try object <| "id"
        name = try object <| "name"
        slug = try object <| "slug"
        alertTitle = try object <| "cta_title"
        alertMsg = try object <| "cta_description"
        changeAmountTitle = try object <| "change_amount_title"
        changeAmountMsg = try object <| "change_amount_description"
    }
}

enum AttendanceStatus: String, Codable {
    case going = "going"
    case notGoing = "not_going"
    case maybeGoing = "maybe_going"
    case invited = "invited"
    case pending = "pending"
    
    var buttonImage: UIImage {
        switch self {
        case .going:
            return .attendingIcon
        case .notGoing:
            return .notAttendingIcon
        case .maybeGoing:
            return .maybeAttendingIcon
        default:
            return .noAttendanceStateIcon
        }
    }
    
    var indicatorColor: UIColor {
        switch self {
        case .going:
            return .green
        case .notGoing:
            return .red
        case .maybeGoing:
            return .orange
        default:
            return .slateGrey
        }
    }
    
    static func forButtonSelected(at index: Int) -> AttendanceStatus {
        switch index {
        case 0:
            return .going
        case 1:
            return .maybeGoing
        case 2:
            return .notGoing
        default:
            return .invited
        }
    }

}

class AttendeeModel: Unmarshaling, Codable {
    var id: Int64
    var status: AttendanceStatus
    var user: UserModel?
    var contribution: AttendeeContributionModel?
    var request: AttendanceRequestModel?
    var updatedAt: TimeInterval
    
    required init(object: MarshaledObject) throws {
        id =            try object <| "id"
        status =        try object <| "status"
        user =          try? object <| "user"
        contribution =  try? object <| "contribution"
        request =       try? object <| "request"
        updatedAt =     try object <| "updated_at"
    }
}

class AttendeeContributionQuoteModel: Unmarshaling {
    var amount: CurrencyAmountModel
    var message: String
    
    required init(object: MarshaledObject) throws {
        amount =    try object <| "amount"
        message =   try object <| "message"
    }
}

class AttendeeContributionModel: Unmarshaling, Codable {
    var id: Int64
    var status: ContributionStatus
    var updatedAt: TimeInterval
    var amount: CurrencyAmountModel
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        status =    try object <| "status"
        updatedAt = try object <| "updated_at"
        amount =    try object <| "amount"
    }
    
    enum ContributionStatus: String, Codable {
        case paid
        case pending
    }
}

class AttendanceRequestModel: Unmarshaling, Codable {
    var id: Int64
    var status: AttendanceRequestStatus
    var updatedAt: TimeInterval
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        status =    try object <| "status"
        updatedAt = try object <| "updated_at"
    }
    
    enum AttendanceRequestStatus: String, Codable {
        case pending
        case accepted
        case rejected
    }
}
