//
//  User.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import Marshal
import FBSDKCoreKit

enum UserEndpointType {
    case me
    case userWithId(Int64)
}

enum FriendsRequestScope: String {
    case all
    case mutual
}

extension SHOAPIClient {
    
    func get(_ endpointType: UserEndpointType, with completion: @escaping ParsingCompletionHandler) {
        
        var endpoint: String
        switch endpointType {
        case .me:
            endpoint = APIEndpoints.getMe
        case .userWithId(let userId):
            endpoint = String(format: APIEndpoints.getUser, arguments: [userId])
        }
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            type: UserModel.self,
                            key: APIKeys.user) { object, error, code in
                                
                                if let user = object as? UserModel {
                                    switch endpointType {
                                    case .me:
                                        UserDefaults.standard.set(user.userId, forKey: UserDefaultKey.currentUserId)
                                        try? CacheManager.storeCurrentUser(user)
                                    case .userWithId(let userId):
                                        try? CacheManager.storeUser(user, withId: userId)
                                    }
                                }
                                completion(object, error, code)
        }
    }
    
    func getMe(with completion: @escaping ParsingCompletionHandler) {
        self.get(.me, with: completion)
    }
    
    func updateMe<T: Marshaling>(with requestmodel: T, completion: @escaping ParsingCompletionHandler) where T.MarshalType == [String: Any] {
        
        self.loadPUTRequest(urlString: APIEndpoints.getMe.versioned,
                            parameters: requestmodel.marshaled(),
                            type: UserModel.self,
                            key: APIKeys.user) { object, error, code in
                                
                                if let user = object as? UserModel {
                                    try? CacheManager.storeCurrentUser(user)
                                }
                                completion(object, error, code)
        }
    }
    
    func addIdentification(with request: IdentificationRequestModel, completion: @escaping ParsingCompletionHandler) {
        
        self.loadPOSTRequest(urlString: APIEndpoints.identification.versioned,
                             parameters: request.marshaled(),
                             type: UserModel.self,
                             key: APIKeys.user,
                             completionHandler: completion)
    }
    
    
    func enableNotifications(_ enabled: Bool, for slug: String, with completion: @escaping ParsingCompletionHandler) {
        let endpoint = APIEndpoints.notificationsSettings
        let params = ["user_notification_settings" : ["notification_settings" : [["slug" : slug, "enabled" : enabled]]]]
        
        self.loadPUTRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: UserModel.self,
                            key: APIKeys.user,
                            completionHandler: completion)
    }
    
    func reportUser(withId userId: Int64, reason: ReportReason, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.reportUser, userId)
        let params = [APIKeys.report: [APIKeys.reportReason: reason.rawValue]]

        self.loadPOSTRequest(urlString: endpoint.versioned,
                             parameters: params,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }
    
    func verifyEmail(with completion: @escaping ParsingCompletionHandler) {
        
        self.loadPOSTRequest(urlString: APIEndpoints.verifyEmail.versioned,
                             type: TypePlaceholder.self,
                             completionHandler: completion)
    }
    
    func checkAvailability(ofEmail email: String, with completionHandler: @escaping ParsingCompletionHandler) {
        let params = ["email": email]
        
        self.loadGETRequest(urlString: APIEndpoints.emailAvailability.versioned,
                            parameters: params,
                            type: AvailabilityModel.self,
                            completionHandler: completionHandler)
    }
    
    func checkAvailability(ofGroupName groupName: String, with completionHandler: @escaping ParsingCompletionHandler) {
        let params = ["group": groupName]
        
        self.loadGETRequest(urlString: APIEndpoints.groupNameAvailability.versioned,
                            parameters: params,
                            type: AvailabilityModel.self,
                            completionHandler: completionHandler)
    }
    
    func getEvents(withScope scope: ProfileSegmentedControlType,
                   for endpointType: UserEndpointType,
                   friendsAttending: Bool = false,
                   offset: Int? = nil,
                   limit: Int? = nil,
                   with completionHandler: @escaping ParsingCompletionHandler) {
        
        var endpoint: String
        switch endpointType {
        case .me:
            endpoint = APIEndpoints.getEventsMe
        case .userWithId(let userId):
            endpoint = String(format: APIEndpoints.getEventsUser, userId)
        }

        var params: [String: Any] = ["scope": scope.stringValue]
        params[APIKeys.offset] = offset
        params[APIKeys.limit] = limit
        
        if friendsAttending {
            params["mutual"] = true
        }
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: ProfileEventsModel.self,
                            completionHandler: completionHandler)
    }
    
    func getFriends(_ endpointType: UserEndpointType = .me, withSearchTerm term: String? = nil,
                    scope: FriendsRequestScope? = nil,
                    forwarding eventId: Int64? = nil,
                    limit: Int,
                    offset: Int,
                    completionHandler: @escaping ParsingCompletionHandler) {
        
        var params = [String: Any]()
        
        params[APIKeys.limit] = limit
        params[APIKeys.offset] = offset
        params[APIKeys.term] = term
        params[APIKeys.scope] = scope
        
        //Used to filter out people who are marked as attening the event
        if let id = eventId {
            params["event_id"] = id
            params["forward"] = true
        }
        
        var endpoint: String
        switch endpointType {
        case .me:
            endpoint = APIEndpoints.getFriends
        case .userWithId(let userId):
            endpoint = String(format: APIEndpoints.getUserFriends, arguments: [userId])
        }
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: UserModel.self,
                            key: APIKeys.friends,
                            completionHandler: completionHandler)
    }
    
    func findFriends(from contacts: [ContactModel],
                     matching term: String?,
                     for eventId: Int64? = nil,
                     completion: @escaping ParsingCompletionHandler) {
        
        var contactsArray = [[String: Any]]()
        contacts.forEach { contact in
            contactsArray.append(contact.marshaled())
        }
        
        var params: [String: Any] = ["contacts": contactsArray]
        params[APIKeys.term] = term
        params["event_id"] = eventId
        
        self.loadPUTRequest(urlString: APIEndpoints.putContacts.versioned,
                            parameters: params,
                            type: ContactsFetchModel.self,
                            completionHandler: completion)
    }
    
    func inviteContact(_ contact: ContactModel, completion: @escaping ParsingCompletionHandler) {
        
        let params = ["contact": contact.inviteParams()]
        
        self.loadPOSTRequest(urlString: APIEndpoints.invite.versioned,
                             parameters: params,
                             type: ResponseMessageModel.self,
                             completionHandler: completion)
    }
    
    func inviteUser(_ user: UserModel, toEventWithId eventID: Int64, completion: ParsingCompletionHandler?) {
        var params = [String: Any]()
        params["invitation_user_id"] = user.userId
        params["event_id"] = eventID
        
        self.loadPOSTRequest(urlString: APIEndpoints.invite.versioned,
                             parameters: params,
                             type: ResponseMessageModel.self,
                             completionHandler: completion)
    }
    
    //MARK: Facebook
    
    func getFBFriends(matching term: String?, withInvitedStateFor eventId: Int64? = nil, with completion: @escaping ParsingCompletionHandler) {
        
        guard let token = FBSDKAccessToken.current() else {
            let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_USER_NO_SESSION".localized]
            let error = NSError(domain: Constants.errorDomain, code: -1013, userInfo: userInfo)
            completion(nil, error, 5)
            return
        }
        
        var params: [String: Any] = ["facebook_access_token": token.tokenString]
        params[APIKeys.term] = term
        params["event_id"] = eventId
        
        self.loadPUTRequest(urlString: APIEndpoints.facebookFriends.versioned,
                            parameters: params,
                            type: UserModel.self,
                            key: APIKeys.facebookFriends,
                            completionHandler: completion)
    }
    
    func importFBEvents(with completion: @escaping ParsingCompletionHandler) {
        guard let token = FBSDKAccessToken.current() else {
            let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_USER_NO_SESSION".localized]
            let error = NSError(domain: Constants.errorDomain, code: -1013, userInfo: userInfo)
            completion(nil, error, 5)
            return
        }
        
        guard token.permissions.contains(FBPermission.userEvents.rawValue) else {
            let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_USER_NO_EVENTS_PERMISSIONS".localized]
            let error = NSError(domain: Constants.errorDomain, code: -1013, userInfo: userInfo)
            completion(nil, error, 5)
            return
        }
        
        let params: [String: Any] = ["facebook_access_token": token.tokenString]
        
        self.loadPUTRequest(urlString: APIEndpoints.facebookEvents.versioned,
                            parameters: params,
                            type: FBEventImportModel.self,
                            completionHandler: completion)
    }
    
}
