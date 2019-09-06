//
//  ContactModel.swift
//  Go
//
//  Created by Lucky on 08/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

private let EmailKey = "email"
private let PhoneKey = "phone"
private let PhoneArrayKey = "phone_numbers"
private let NameKey = "name"

class ContactModel: Marshaling, Unmarshaling, Codable {
    
    var name: String
    var phoneNumbers: [String]
    var email: String?
    var invited: Bool = false
    var selectedNumber: String?

    required init(object: MarshaledObject) throws {
        name = try object <| NameKey
        phoneNumbers = (try? object <| PhoneArrayKey) ?? []
        email = try? object <| EmailKey
        invited = (try object <| "invited") ?? false
    }
    
    init(name: String, phoneNumbers: [String], email: String?) {
        self.name = name
        self.phoneNumbers = phoneNumbers
        self.email = email
    }
    
    func marshaled() -> [String: Any] {
        var dict = [String: Any]()
        
        dict[NameKey] = self.name
        dict[PhoneArrayKey] = self.phoneNumbers
        dict[EmailKey] = self.email
        
        return dict
    }
    
    func inviteParams() -> [String: Any] {
        var dict = [String: Any]()
        
        dict[NameKey] = self.name
        dict[PhoneKey] = self.selectedNumber ?? self.phoneNumbers.first
        dict[EmailKey] = self.email
        
        return dict
    }
}

class ContactsFetchModel: Unmarshaling {
    
    var users: [UserModel]
    var contacts: [ContactModel]
    
    required init(object: MarshaledObject) throws {
        users =     (try? object <| "users") ?? []
        contacts =  (try? object <| "contacts") ?? []
    }
    
}
