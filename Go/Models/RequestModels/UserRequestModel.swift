//
//  UserRequestModel.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import UIKit
import Marshal

enum ValidationState {
    case valid
    case invalid(error: String)
}

//MARK: - User profile

struct UserProfileRequestModel: Marshaling {
    var businessName: String?
    var firstName: String?
    var lastName: String?
    var description: String?
    var avatarImageUrl: String?
    var coverImageUrl: String?
    var dateOfBirth: TimeInterval?
    var gender: String?
    var phoneNumber: String?
    var eighteenPlus: Bool?
    var syncCalendar: Bool?

    //Not to be added to params
    var image: UIImage?
    var userType: UserType?

    init(with userModel: UserModel) {
        self.userType = userModel.userType
        self.businessName = userModel.businessName
        self.firstName = userModel.firstName
        self.lastName = userModel.lastName
        self.description = userModel.userDescription
        self.dateOfBirth = userModel.dateOfBirth
        self.gender = userModel.gender
        self.phoneNumber = userModel.phoneNumber
        self.eighteenPlus = userModel.eighteenPlus
        self.syncCalendar = userModel.saveEventsToCalendar
    }
    
    func marshaled() -> [String: Any] {
        var user = [String: Any]()
        
        user["business_name"] = self.businessName
        user["first_name"] = self.firstName
        user["last_name"] = self.lastName
        user["description"] = self.description
        user["image_url"] = self.avatarImageUrl
        user["cover_image_url"] = self.coverImageUrl
        user["date_of_birth"] = self.dateOfBirth
        user["gender"] = self.gender
        user["phone_number"] = self.phoneNumber
        user["eighteen_plus"] = self.eighteenPlus
        user["save_events_to_calendar"] = self.syncCalendar
        
        return ["user": user]
    }
    
    func validate() -> ValidationState {
        
        if self.userType == .business && self.businessName?.isEmpty ?? true {
            return ValidationState.invalid(error: "EDIT_PROFILE_NO_COMPANY_NAME".localized)
        }
        
        guard let firstName = self.firstName, !firstName.isEmpty else {
            return ValidationState.invalid(error: "EDIT_PROFILE_NO_FNAME".localized)
        }
        guard let surname = self.lastName, !surname.isEmpty else {
            return ValidationState.invalid(error: "EDIT_PROFILE_NO_SNAME".localized)
        }

        return .valid
    }
}

//MARK: - User notification prefs

struct UserNotficationPreferenceRequestModel: Marshaling {
    var notificationsEnabled: Bool?
    
    init(with userModel: UserModel) {
        self.notificationsEnabled = userModel.notificationsEnabled
    }
    
    func marshaled() -> [String: Any] {
        var user = [String: Any]()

        user["notifications_enabled"] = self.notificationsEnabled
        
        return ["user": user]
    }
}

//MARK: - User verifications details

struct UserVerificationDetailsRequestModel: Marshaling {
    var dateOfBirth: TimeInterval?
    var gender: String?
    var countryCode: String?
    var accountType: String?
    var address: AddressModel
    var phoneNumber: String?
    
    init(with userModel: UserModel) {
        self.dateOfBirth = userModel.dateOfBirth
        self.gender = userModel.gender
        self.countryCode = userModel.countryOfResidence?.alpha2
        self.accountType = userModel.accountType
        self.address = userModel.address
        self.phoneNumber = userModel.phoneNumber
    }

    func marshaled() -> [String: Any] {
        var user = [String: Any]()
        
        user["date_of_birth"] = self.dateOfBirth
        user["gender"] = self.gender
        user["country_code"] = self.countryCode
        user["account_type"] = self.accountType
        user["phone_number"] = self.phoneNumber
        user["address"] = self.address.marshaled()
        
        return ["user": user]
    }
    
    func validate() -> ValidationState {
        
        guard self.dateOfBirth != nil else {
            return ValidationState.invalid(error: "USER_DETAILS_NO_DOB".localized)
        }
        guard let gender = self.gender, !gender.isEmpty else {
            return ValidationState.invalid(error: "USER_DETAILS_NO_GENDER".localized)
        }
        guard let accountType = self.accountType, !accountType.isEmpty else {
            return ValidationState.invalid(error: "USER_DETAILS_NO_ACCOUNT_TYPE".localized)
        }
        guard let country = self.countryCode, !country.isEmpty else {
            return ValidationState.invalid(error: "USER_DETAILS_NO_COUNTRY".localized)
        }
        
        guard let phoneNumber = self.phoneNumber, !phoneNumber.isEmpty else {
            return ValidationState.invalid(error: "USER_DETAILS_NO_PHONE_NUMBER".localized)
        }
        
        return self.address.validate()
    }
}

//MARK: - User business details

struct UserBusinessDetailsRequestModel: Marshaling {
    var name: String?
    var taxId: String?
    var address: AddressModel
    
    init(with businessModel: BusinessDetailsModel) {
        self.name = businessModel.name
        self.taxId = businessModel.taxId
        self.address = businessModel.address
    }
    
    func marshaled() -> [String: Any] {
        var details = address.marshaled()
        
        details["name"] = self.name
        details["tax_id"] = self.taxId
        
        return ["user": ["business": details]]
    }
    
    func validate() -> ValidationState {
        
        guard let name = self.name, !name.isEmpty else {
            return ValidationState.invalid(error: "BUSINESS_DETAILS_NO_NAME".localized)
        }
        guard let taxId = self.taxId, !taxId.isEmpty else {
            return ValidationState.invalid(error: "BUSINESS_DETAILS_NO_TAX_ID".localized)
        }
        
        return self.address.validate()
    }
}

//MARK: - User email verification

struct UserEmailRequestModel: Marshaling {
    var email: String?
    
    func marshaled() -> [String: Any] {
        var user = [String: Any]()
        
        user["email"] = email
        
        return ["user": user]
    }
    
    func validate() -> ValidationState {
        
        guard let email = self.email else {
            return .invalid(error: "LOGIN_ERROR_NO_EMAIL".localized)
        }
        guard email.isValidEmail() else {
            return .invalid(error: "LOGIN_ERROR_INVALID_EMAIL".localized)
        }
        
        return .valid
    }
}

struct UserFBRequestModel: Marshaling {
    var userId: String
    
    func marshaled() -> [String: Any] {
        return ["facebook_uid" : userId]
    }
}

struct UserCalendarPrefsRequestModel: Marshaling {
    var saveEventsToCalendar: Bool
    
    func marshaled() -> [String: Any] {
        return ["save_events_to_calendar" : saveEventsToCalendar]
    }
}

struct UserInterestsRequestModel: Marshaling {
    var tagIds: [Int]
    
    func marshaled() -> [String: Any] {
        var user = [String: Any]()
        
        user["tags"] = tagIds
        
        return ["user": user]
    }
}
