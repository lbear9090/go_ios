//
//  EventRequestModel.swift
//  Go
//
//  Created by Lucky on 07/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

let InvalidDefaultValue = -1

class AddEventRequestModel: Marshaling {
    var title: String?
    var description: String?
    var time: TimeInterval?
    var date: TimeInterval?
    var eighteenPlus: Bool = false
    var latitude: Double?
    var longitude: Double?
    var privateEvent: Bool = false {
        didSet {
            if self.privateEvent {
                self.publicByInviteEvent = false
            }
        }
    }
    var publicByInviteEvent: Bool = false {
        didSet {
            if self.publicByInviteEvent {
                self.privateEvent = false
            }
        }
    }
    var forwarding: Bool = true
    var limitedSpaces: Bool = false
    var guestCap: Int = InvalidDefaultValue
    var allowChat: Bool = true
    var showTimeline: Bool = true
    var categories: String?
    var bring: String?
    var attendees: [UserModel] = []
    var inviteAllFriends: Bool = false
    var contribution: ContributionRequestModel?
    var mediaItems: [MediaRequestModel] = []
    var ticketURL: String?
    
    //Not to be added to dictionary
    var contributionsEnabled: Bool = false
    var eventAddress: String?
    var ticketsSaleAllowed: Bool = false
    
    func marshaled() -> [String: Any] {
        var event = [String: Any]()
        
        event["title"] = title
        event["description"] = description
        event["time"] = time
        event["date"] = date
        event["eighteen_plus"] = eighteenPlus
        event["latitude"] = latitude
        event["longitude"] = longitude
        event["display_address"] = eventAddress
        event["private_event"] = privateEvent
        event["attendance_acceptance_required"] = publicByInviteEvent
        event["event_forwarding"] = forwarding
        event["categories"] = categories
        event["allow_chat"] = allowChat
        event["show_timeline"] = showTimeline
        event["bring"] = bring
        event["maximum_attendees"] = self.guestCap
        event["attendees"] = attendees.compactMap { $0.userId }
        event["contribution_details"] = contribution?.marshaled()
        event["media_items"] = mediaItems.map { mediaItem -> [String: Any] in
            mediaItem.marshaled()
        }
        if let url = self.ticketURL, ticketsSaleAllowed {
            event["ticket_details"] = ["url": url]
        }
        
        return ["event": event]
    }
    
    func validate() -> ValidationState {
        
        guard let title = self.title, !title.isEmpty else {
            return ValidationState.invalid(error: "ADD_EVENT_NO_TITLE".localized)
        }
        
        guard let description = self.description, !description.isEmpty else {
            return ValidationState.invalid(error: "ADD_EVENT_NO_TITLE".localized)
        }
        
        guard self.time != nil else {
            return ValidationState.invalid(error: "ADD_EVENT_NO_TIME".localized)
        }
        
        guard self.date != nil else {
            return ValidationState.invalid(error: "ADD_EVENT_NO_DATE".localized)
        }
        
        guard self.latitude != nil && self.longitude != nil else {
            return ValidationState.invalid(error: "ADD_EVENT_NO_LOCATION".localized)
        }
        
        guard let categories = self.categories, !categories.isEmpty else {
            return ValidationState.invalid(error: "ADD_EVENT_NO_CATEGORIES".localized)
        }
        
        if self.limitedSpaces && self.guestCap < 1 {
            return ValidationState.invalid(error: "ADD_EVENT_NO_GUEST_CAP".localized)
        }
        
        if self.ticketsSaleAllowed && (self.ticketURL?.isEmpty ?? true){
            return ValidationState.invalid(error: "ADD_EVENT_TICKET_URL_MISSING".localized)
        }
        
        return ValidationState.valid
    }
    
    init() { }
    
    init(forEvent event: EventModel) {
        self.title = event.title
        self.description = event.description
        self.time = event.time
        self.date = event.date
        self.eighteenPlus = event.eighteenPlus
        self.latitude = event.latitude
        self.longitude = event.longitude
        self.privateEvent = event.isPrivate
        self.publicByInviteEvent = event.isPublicByInvite
        self.forwarding = event.allowsForwarding
        self.allowChat = event.allowChat
        self.showTimeline = event.showTimeline
        self.categories = event.categories
        self.bring = event.bring
        self.guestCap = event.maximumAttendees
        self.limitedSpaces = (event.maximumAttendees == InvalidDefaultValue) ? false : true
        self.attendees = event.attendees.compactMap { $0.user }
        self.eventAddress = event.address
        
        if let eventContribution = event.contribution {
            self.contributionsEnabled = true
            self.contribution = ContributionRequestModel(fromModel: eventContribution)
        }
        
        self.ticketsSaleAllowed = (event.eventTicketURL != nil)
        self.ticketURL = event.eventTicketOriginalURL
        
        self.mediaItems = event.mediaItems.map({ MediaRequestModel(fromModel: $0)})
    }

}

struct EventAttendeesRequestModel: Marshaling {
    var attendees: [UserModel]
    var inviteAllFriends: Bool
    
    func marshaled() -> [String: Any] {
        var event = [String: Any]()

        event["attendees"] = attendees.compactMap { $0.userId }
        event["invite_all_friends"] = self.inviteAllFriends
        
        return ["event": event]
    }
}

class ContributionRequestModel: Marshaling {
    
    var amountCents: Int = 0
    var reason: String?
    var optional: Bool = false

    func marshaled() -> [String: Any] {
        var contribution = [String: Any]()
        
        contribution["amount_cents"] = amountCents
        contribution["reason"] = reason
        contribution["optional"] = optional
        contribution["event_contribution_type"] = "contribution"
        
        return contribution
    }
    
    init() { }
    
    init(fromModel model: EventContributionModel) {
        self.amountCents = model.amount.cents
        self.reason = model.reason
        self.optional = model.optional
    }
}

class MediaRequestModel: Marshaling {
    var type: MediaType?
    var url: String?
    var text: String?
    
    init(type: MediaType, url: String) {
        self.type = type
        self.url = url
    }
    
    init(text: String) {
        self.type = .text
        self.text = text
    }
    
    func marshaled() -> [String: Any] {
        var mediaItem = [String: Any]()
        
        mediaItem["type"] = type?.rawValue
        mediaItem["url"] = url
        mediaItem["content"] = text
        
        return mediaItem
    }
    
    init() { }
    
    init(fromModel model: MediaModel) {
        self.type = model.type
        
        switch self.type {
        case .image?:
            self.url = model.images?.originalUrl
        case .video?:
            self.url = model.videoUrl
        case .text?:
            self.text = model.text
        case .none:
            break
        }
        
    }
}
