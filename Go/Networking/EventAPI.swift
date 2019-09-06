//
//  EventAPI.swift
//  Go
//
//  Created by Lucky on 28/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

enum ReportReason: String {
    case spam
    case inappropriate
}

extension SHOAPIClient {
    
    func getEvent(withId eventId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.event, eventId)
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            type: EventModel.self,
                            key: APIKeys.events,
                            completionHandler: completionHandler)
    }
    
    func createEvent(with request: AddEventRequestModel, completionHandler: @escaping ParsingCompletionHandler) {
        
        self.loadPOSTRequest(urlString: APIEndpoints.events.versioned,
                             parameters: request.marshaled(),
                             type: EventModel.self,
                             key: APIKeys.event,
                             completionHandler: completionHandler)
        
    }
    
    func updateEvent<T: Marshaling>(eventID: Int64,
                                    request: T,
                                    completionHandler: @escaping ParsingCompletionHandler) where T.MarshalType == [String: Any] {
        let endpoint = String(format: APIEndpoints.event, eventID)
        
        self.loadPUTRequest(urlString: endpoint.versioned,
                            parameters: request.marshaled(),
                            type: EventModel.self,
                            key: APIKeys.event,
                            completionHandler: completionHandler)
    }
    
    func deleteEvent(withId eventId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.event, eventId)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    func forwardEvent(withId eventId: Int64, toUsers users: [Int64], completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.eventForwarding, eventId)
        let params = ["share": ["users": users]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: EventShareModel.self,
                             key: APIKeys.eventShare,
                             completionHandler: completionHandler)
    }
    
    func reportEvent(withId eventId: Int64, reason: ReportReason, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.reportEvent, eventId)
        let params = [APIKeys.report: [APIKeys.reportReason: reason.rawValue]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }
    
    //MARK: - Attendance
    
    func setAtttendanceStatus(_ status: AttendanceStatus,
                              forEventId eventId: Int64,
                              completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.eventAttendance, eventId)
        let params = ["attendee": ["status": status.rawValue]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: AttendeeModel.self,
                             key: APIKeys.attendee,
                             completionHandler: completionHandler)
    }
    
    func updateAttendanceStatus(to status: AttendanceStatus,
                                forAttendeeId attendeeId: Int64,
                                forEventId eventId: Int64,
                                completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.updateEventAttendance, eventId, attendeeId)
        let params = ["attendee": ["status": status.rawValue]]
        
        self.loadPUTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: AttendeeModel.self,
                             key: APIKeys.attendee,
                             completionHandler: completionHandler)
    }
    
    func getEventAttendees(for eventId: Int64, withOffset offset: Int, limit: Int, searchTerm: String? = nil,completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.eventAttendees, eventId)
        
        var params: [String: Any] = [APIKeys.limit: limit,
                                     APIKeys.offset: offset]
        params["term"] = searchTerm

        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: AttendeeModel.self,
                            key: APIKeys.attendees,
                            completionHandler: completionHandler)
    }
    
    func getUninvitedFriends(for eventId: Int64, withTerm term: String?, offset: Int, limit: Int, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.eventUninvitedFriends, eventId)
        
        var params: [String: Any] = [APIKeys.limit: limit,
                                     APIKeys.offset: offset]
        params[APIKeys.term] = term
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: UserModel.self,
                            key: APIKeys.friends,
                            completionHandler: completionHandler)
    }
    
    func acceptAttendanceRequest(for eventId: Int64, attendeeId: Int64, requestId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.acceptEventRequest, eventId, attendeeId, requestId)
        
        self.loadPUTRequest(urlString: endpoint.versioned,
                            type: AttendanceRequestModel.self,
                            key: APIKeys.request,
                            completionHandler: completionHandler)
    }
    
    func rejectAttendanceRequest(for eventId: Int64, attendeeId: Int64, requestId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.rejectEventRequest, eventId, attendeeId, requestId)

        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: AttendanceRequestModel.self,
                               key: APIKeys.request,
                               completionHandler: completionHandler)
    }
    
    //MARK: - Contributions
    
    func getTotalContribution(for amount: Int,
                              on eventId: Int64,
                              from attendeeId: Int64,
                              completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.eventCalculateContribution, eventId, attendeeId)
        let params = ["contribution": ["amount_cents": amount]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: AttendeeContributionQuoteModel.self,
                             key: APIKeys.price,
                             completionHandler: completionHandler)
    }
    
    func addContribution(of amount: Int,
                         to eventId: Int64,
                         from attendeeId: Int64,
                         completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.eventContribution, eventId, attendeeId)
        
        let params = ["contribution": ["amount_cents": amount]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: AttendeeContributionModel.self,
                             key: APIKeys.contribution,
                             completionHandler: completionHandler)
    }
    
    //MARK: - Timeline
    
    func getTimeline(for eventId: Int64, limit: Int, offset: Int, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.eventTimeline, eventId)
        let params = [APIKeys.limit : limit,
                      APIKeys.offset : offset]
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: FeedItemModel.self,
                            key: APIKeys.feedItems,
                            completionHandler: completionHandler)
    }
    
    func createTimelineItem(with request: MediaRequestModel, for eventId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
       
        let endpoint = String(format: APIEndpoints.eventTimeline, eventId)
        let params = ["timeline_item": ["media_items": [request.marshaled()]]]
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: FeedItemModel.self,
                             key: APIKeys.feedItem,
                             completionHandler: completionHandler)
    }
    
    func reportTimelineItem(with timelineId: Int64, from eventId: Int64, reason: ReportReason, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.reportTimelineItem, eventId, timelineId)
        let params = [APIKeys.report: [APIKeys.reportReason: reason.rawValue]]

        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }
    
    func likeTimelineItem(with timelineId: Int64, from eventId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.likeTimelineItem, eventId, timelineId)
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }
    
    func unlikeTimelineItem(with timelineId: Int64, from eventId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.likeTimelineItem, eventId, timelineId)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }
    
    func deleteTimelineItem(with timelineId: Int64, from eventId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.deleteTimelineItem, eventId, timelineId)

        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    //MARK: - Invites
    
    func inviteContact(_ contact: ContactModel, toEventWithId eventID: Int64, completion: ParsingCompletionHandler?) {
        let params = ["contact": contact.inviteParams()]
        
        let endpoint = String(format: APIEndpoints.inviteContactToEvent.versioned, eventID)
        
        self.loadPOSTRequest(urlString: endpoint,
                             parameters: params,
                             type: ResponseMessageModel.self,
                             completionHandler: completion)
    }
    
}
