//
//  Constants.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

struct Constants {
    static let errorDomain: String = "com.go.error"
    static let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    static let minPasswordLength: Int = 6
    static let businessAccountType: String = "company"
    
    static var stripePublishableKey: String {
        #if RELEASE_BUILD
            return "pk_live_aLZndZ8eU10DVeTXLn7oJ3g6"
        #elseif (BETA_BUILD)
            return "pk_test_cx54ILItLp0Zv9hEpA34R8Gl"
        #else
            return "pk_test_cx54ILItLp0Zv9hEpA34R8Gl"
        #endif
    }
    
    static let secondsInADay: Double = 24*60*60
    static let branchEventIDKey: String = "event_id"
    static let mediaHeight: CGFloat = 224.0
    static var googleMapsDirectionsURL = "https://www.google.com/maps/dir/?api=1&destination=%f,%f"
}

struct PushConstants {
    static let APSKey = "aps"
    static let badgeKey = "badge"
    static let alertKey = "alert"
    static let actionKey = "action"
    static let extraKey = "extra"
    static let notificationTypeKey = "type"
    static let actionTypeKey = "t"
    static let soundFileKey = "push_sound"
    static let messageKey = "m"
}

struct UserDefaultKey {
    static let currentUserId: String = "current_user_id"
    static let pushNotificationToken: String = "push_notification_token"
    static let unreadNotificationCount: String = "unread_notifications_count"
    static let unreadMessageCount: String = "unread_message_count"
    static let calendarPromptShown: String = "did_show_calendar_prompt"
    static let showAddFriendsPrompt: String = "show_add_friends_prompt"
}

struct APIConstants: APIConstantsProvider {
    static let scopes: String = "basic"
    static let grantType: String = "password"
    static let authorization: String = "Authorization"
    static let version: String = "api/v1/"
    static let noPaymentMethodCode: Int = 10002
}

struct APIEndpoints {
    // MARK: Configurations
    static let configurations: String = "configurations/generic"

    // MARK: Oauth
    static let authToken: String = "oauth/token"
    static let revokeAuthToken: String = "oauth/revoke"
    
    // MARK: User
    static let registration: String = "users"
    static let resetPassword: String = "users/reset_password.json"
    static let groupNameAvailability: String = "users/group"
    static let emailAvailability: String = "users/email"
    
    static let getMe: String = "users/me"
    static let getUser: String = "users/%d"
    static let changePassword: String = "users/me/password"
    static let notifications: String = "users/me/notifications"
    static let notificationsRead: String = "users/me/notifications/%d"
    static let notificationsSettings: String = "users/me/notification_settings"
    static let deviceRegistration: String = "users/me/devices"
    static let identification: String = "users/me/identifications"
    static let verifyEmail: String = "users/me/send_verification_email"
    static let facebookFriends: String = "users/me/facebook_friends"
    static let facebookEvents: String = "users/me/facebook_events"
    static let getEventsMe: String = "users/me/events"
    static let getEventsUser: String = "users/%d/events"
    static let reportUser: String = "users/%d/reports"
    static let getFriends: String = "users/me/friends"
    static let getUserFriends: String = "users/%d/friends"
    static let putContacts: String = "users/me/contacts"
    static let invite: String = "users/me/invite"

    static let paymentMethods: String = "users/me/payment_methods"
    static let deletePaymentMethod: String = "users/me/payment_methods/%d?payment_method_provider=stripe"
    static let defaultPaymentMethod: String = "users/me/payment_methods/%d/default"
    
    static let payoutMethods: String = "users/me/payout_methods"
    static let deletePayoutMethod: String = "users/me/payout_methods/%@"
    static let defaultPayoutMethod: String = "users/me/payout_methods/%@/default"
    
    static let friends: String = "users/%d/friends"
    static let friendRequest: String = "users/%d/friend_requests/"
    static let cancelFriendRequest: String = "users/me/friend_requests/%d/cancel"
    static let acceptFriendRequst: String = "users/me/friend_requests/%d/accept"
    static let rejectFriendRequst: String = "users/me/friend_requests/%d/reject"
    
    // MARK: Search
    static let locationSearch: String = "search/locations"
    static let userSearch: String = "search/users"
    static let tagSearch: String = "search/tags"
    static let addressSearch: String = "search/lookup"

    // MARK: Tags
    static let tags: String = "tags"
    static let tagEvents: String = "tags/%@/events"
    
    // MARK: Locations
    static let locationEvents: String = "locations/events"
    
    // MARK: Events
    static let events: String = "events"
    static let event: String = "events/%d"
    static let eventAttendance: String = "events/%d/attendees"
    static let updateEventAttendance: String = "events/%d/attendees/%d"
    static let reportEvent: String = "events/%d/reports"
    static let eventContribution: String = "events/%d/attendees/%d/contributions"
    static let eventCalculateContribution: String = "events/%d/attendees/%d/contributions/price"
    static let eventAttendees: String = "events/%d/attendees"
    static let eventUninvitedFriends: String = "events/%d/friends/uninvited"
    static let acceptEventRequest: String = "events/%d/attendees/%d/requests/%d/accept"
    static let rejectEventRequest: String = "events/%d/attendees/%d/requests/%d/reject"
    static let eventForwarding: String = "events/%d/shares"
    static let eventTimeline: String = "events/%d/timeline"
    static let likeTimelineItem: String = "events/%d/timeline/%d/likes"
    static let reportTimelineItem: String = "events/%d/timeline/%d/reports"
    static let deleteTimelineItem: String = "events/%d/timeline/%d"
    static let inviteContactToEvent: String = "events/%d/contacts/invites"
    
    // MARK: Comments
    static let timelineComments: String = "events/%d/timeline/%d/comments"
    static let deleteComment: String = "events/%d/timeline/%d/comments/%d"
    static let reportComment: String = "events/%d/timeline/%d/comments/%d/reports"

    // MARK: Chats
    static let conversations: String = "conversations"
    static let conversation: String = "conversations/%ld"
    static let conversationsMessages: String = "conversations/%ld/messages"
    static let muteConversation: String = "conversations/%ld/mute"
    static let deleteConversation: String = "conversations/%ld"
    static let conversationParticipant: String = "conversations/%d/participants/%d"
    static let conversationParticipants: String = "conversations/%d/participants"

    // MARK: Feed
    static let feed: String = "feed"
    static let featuredFeed: String = "home/featured"
    static let friendsFeed: String = "home/friends"
    static let groupsFeed: String = "home/groups"
}

struct APIKeys {
    static let limit: String = "limit"
    static let offset: String = "offset"
    static let token: String = "token"
    static let pushToken: String = "push_token"
    static let location: String = "location"
    static let locations: String = "locations"
    static let user: String = "user"
    static let users: String = "users"
    static let notifications: String = "notifications"
    static let latitude: String = "latitude"
    static let longitude: String = "longitude"
    static let filters: String = "filters"
    static let boundingBox: String = "bounding_box"
    static let bottom: String = "bottom"
    static let left: String = "left"
    static let top: String = "top"
    static let right: String = "right"
    static let device: String = "device"
    static let configuration: String = "configuration"
    static let paymentMethods: String = "payment_methods"
    static let payoutMethods: String = "payout_methods"
    static let facebookFriends: String = "facebook_friends"
    static let tags: String = "tags"
    static let event: String = "event"
    static let events: String = "events"
    static let eventShare: String = "share"
    static let attendee: String = "attendee"
    static let attendees: String = "attendees"
    static let price: String = "price"
    static let contribution: String = "contribution"
    static let friends: String = "friends"
    static let conversations: String = "conversations"
    static let conversation: String = "conversation"
    static let participants: String = "participants"
    static let messages: String = "messages"
    static let message: String = "message"
    static let feed: String = "feed"
    static let feedItem: String = "feed_item"
    static let feedItems: String = "feed_items"
    static let comment: String = "comment"
    static let comments: String = "comments"
    static let request: String = "request"
    static let report: String = "report"
    static let reportReason: String = "reason"
    static let search: String = "search"
    static let term: String = "term"
    static let scope: String = "scope"
}

extension DateFormat {
    public static let time = DateFormat(value: "HH:mm")
    public static let medium = DateFormat(value: "MMM dd, yyyy")
    public static let short = DateFormat(value: "dd/MM/yy")
    public static let shorthand = DateFormat(value: "E d MMM")
    public static let timeDate = DateFormat(value: "HH:mm dd/MM/yyyy")
    public static let mediumDate = DateFormat(value: "dd MMM yyyy")
}

// MARK: - Versioned URL

public extension String {
    
    public var versioned: String {
        return APIConstants.version + self
    }
    
}

extension Notification.Name {
    static let stopPlayingVideo = Notification.Name("VideoPlayerShouldStopPlayingVideo")
}

