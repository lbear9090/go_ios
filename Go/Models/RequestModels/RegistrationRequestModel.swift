//
//  RegistrationRequestModel.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class RegistrationRequestModel {
    
    var scopes: String = APIConstants.scopes
    var clientID: String = SHOConfigurations.clientID.value
    var clientSecret: String = SHOConfigurations.clientSecret.value
    var accountType: String?
    var groupName: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var avatarUrl: String?
    var interests: [Int]?
    
    init() {}
    
    init(firstName: String?, lastName: String?, email: String?, password: String?, avatarUrl: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.avatarUrl = avatarUrl
    }
    
    func validate() -> ValidationState {
        
        guard let fName = firstName, !fName.isEmpty else {
            return ValidationState.invalid(error: "REGISTRATION_ERROR_FIRST_NAME".localized)
        }
        guard let lName = lastName, !lName.isEmpty else {
            return ValidationState.invalid(error: "REGISTRATION_ERROR_LAST_NAME".localized)
        }
        guard let email = email, !email.isEmpty else {
            return ValidationState.invalid(error: "REGISTRATION_ERROR_EMAIL".localized)
        }
        guard email.isValidEmail() else {
            return ValidationState.invalid(error: "REGISTRATION_ERROR_INVALID_EMAIL".localized)
        }
        guard let pword = password, !pword.isEmpty else {
            return ValidationState.invalid(error: "REGISTRATION_ERROR_PASSWORD".localized)
        }

        return ValidationState.valid
    }
    
    enum ValidationState {
        case valid
        case invalid(error: String)
    }
}

extension RegistrationRequestModel: Marshaling {
    
    func marshaled() -> [String: Any] {
        
        var userDict: [String: Any] = [:]

        userDict["first_name"] = self.firstName
        userDict["last_name"] = self.lastName
        userDict["email"] = self.email
        userDict["password"] = self.password
        userDict["image_url"] = self.avatarUrl
        userDict["user_type"] = self.accountType
        userDict["business_name"] = self.groupName
        userDict["tags"] = self.interests
        
        var requestHash: [String: Any] = [:]
        requestHash["scopes"] = self.scopes
        requestHash["client_id"] = self.clientID
        requestHash["client_secret"] = self.clientSecret
        requestHash["user"] = userDict
        
        return requestHash
    }
}
