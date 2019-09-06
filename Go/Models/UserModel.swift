//
//  UserModel.swift
//  Go
//
//  Created by Lucky on 17/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Marshal

enum UserType: String, Codable {
    case personal
    case business
}

class UserModel: Unmarshaling, Codable, Equatable {
    var userId: Int64
    var businessName: String?
    private var fullName: String
    var firstName: String
    var lastName: String
    var userDescription: String
    var email: String?
    var gender: String?
    var dateOfBirth: TimeInterval?
    var address: AddressModel
    var phoneNumber: String?
    var avatarImage: ImagesModel?
    var coverImage: ImagesModel?
    var userType: UserType?
    var countryOfResidence: CountryModel?
    var accountType: String?
    var businessDetails: BusinessDetailsModel
    var requiredVerifications: VerificationsModel?
    var notificationPrefs: [NotificationPreferenceModel]
    var friendCount: Int?
    var mutualFriendCount: Int?
    var eventCount: Int
    var attendingEventCount: Int
    var eighteenPlus: Bool?
    var notificationsEnabled: Bool?
    var friendRequestId: Int64?
    var isFriend: Bool
    var isRequestedFriend: Bool
    var isActive: Bool?
    var isSuspended: Bool?
    var saveEventsToCalendar: Bool
    var tags: [TagModel]
    var invited: Bool
    var forwarded: Bool
    
    required init(object: MarshaledObject) throws {
        userId =                try object <| "id"
        businessName =          try object <| "business_name"
        fullName =              (try? object <| "name") ?? ""
        firstName =             (try? object <| "first_name") ?? ""
        lastName =              (try? object <| "last_name") ?? ""
        userDescription =       (try? object <| "description") ?? ""
        email =                 (try? object <| "email")
        gender =                try? object <| "gender"
        dateOfBirth =           try? object <| "date_of_birth"
        address =               (try? object <| "address") ?? AddressModel()
        phoneNumber =           try? object <| "phone_number"
        avatarImage =           try? object <| "images"
        coverImage =            try? object <| "cover_images"
        userType =              try? object <| "user_type"
        countryOfResidence =    try? object <| "country"
        accountType =           try? object <| "account_type"
        businessDetails =       (try? object <| "business_details") ?? BusinessDetailsModel()
        requiredVerifications = try? object <| "seller_verifications_required"
        notificationPrefs =     (try? object <| "notification_settings.settings") ?? []
        friendCount =           try? object <| "friend_count"
        mutualFriendCount =     try? object <| "mutual_friends_count"
        eventCount =            try object <| "event_count"
        attendingEventCount =   try object <| "attending_event_count"
        eighteenPlus =          (try? object <| "eighteen_plus") ?? false
        notificationsEnabled =  try? object <| "notifications_enabled"
        friendRequestId =       try? object <| "pending_friend_request.id"
        isFriend =              try object <| "friend"
        isRequestedFriend =     try object <| "friend_request_pending"
        isActive =              try? object <| "active"
        isSuspended =           try? object <| "suspended"
        saveEventsToCalendar =  (try? object <| "save_events_to_calendar") ?? false
        tags =                  (try? object <| "tags") ?? []
        invited =               (try? object <| "invited") ?? false
        forwarded =             (try? object <| "shared") ?? false
    }
    
    static func ==(lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var displayName: String {
        if userType == .business {
            return businessName!
        }
        return fullName
    }
}

class VerificationsModel: Unmarshaling, Codable {
    
    var dateOfBirth: Bool
    var gender: Bool
    var email: Bool
    var identification: Bool
    var address: Bool
    var country: Bool
    var bankAccount: Bool
    var accountType: Bool
    var businessDetails: Bool
    
    required init(object: MarshaledObject) throws {
        dateOfBirth =       (try? object <| "date_of_birth") ?? true
        gender =            (try? object <| "gender") ?? true
        email =             (try? object <| "email") ?? true
        identification =    (try? object <| "identification") ?? true
        address =           (try? object <| "address") ?? true
        country =           (try? object <| "country") ?? true
        bankAccount =       (try? object <| "bank_account") ?? true
        accountType =       (try? object <| "account_type") ?? true
        businessDetails =   (try? object <| "business_details") ?? true
    }
    
    var detailsVerificationRequired: Bool {
        return dateOfBirth || gender || accountType ||
            country || address || accountType
    }
    
    var allFulfilled: Bool {
        return !(detailsVerificationRequired || email ||
            identification || bankAccount || businessDetails)
    }
}

class NotificationPreferenceModel: Unmarshaling, Codable {
    
    var id: Int64
    var name: String
    var description: String
    var slug: String
    var enabled: Bool
    
    required init(object: MarshaledObject) throws {
        id =            try object <| "notification_setting.id"
        name =          try object <| "notification_setting.name"
        description =   try object <| "notification_setting.description"
        slug =          try object <| "notification_setting.slug"
        enabled =       try object <| "enabled"
    }
}
