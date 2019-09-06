//
//  CachingManager.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Cache
import IGListKit

struct CacheManager {
    
    typealias CacheUserCompletion = (_ user: UserModel?, _ error: Error?) -> Void
    
    //MARK: - Keys
    
    static let currentUserKey: String = "current_user"
    static let userKey: String = "user_%d"
    static let configurationsKey: String = "configurations"
    static let pendingShareEventId: String = "pending_share_event_id"
    static let contactsKey: String = "contacts"
    static let feedItemsKey: String = "feedItems"
    static let featuredFetchKey: String = "featuredFetch"
    static let conversationsListKey: String = "conversationsList"
    static let notificationsListKey: String = "notificationsList"
    
    //MARK: - Properties
    
    static let diskConfig = DiskConfig(name: "RubanCache",
                                       expiry: .never,
                                       maxSize: 100000, //1OOMB
        protectionType: .complete)
    
    static let memoryConfig = MemoryConfig(expiry: .never,
                                           countLimit: 0,
                                           totalCostLimit: 10000) //10MB
        
    static func getStorage() throws ->  Storage {
        return try Storage(diskConfig: CacheManager.diskConfig,
                           memoryConfig: CacheManager.memoryConfig)
    }
    
    static func clearCache() {
        let configuration = try? self.getConfigurations()
        try? self.getStorage().removeAll()
        if let config = configuration {
            try? self.storeConfigurations(config)
        }
    }
    
    enum FallbackPolicy {
        case none
        case network(controller: SHOSpinner)
    }
    
    //MARK: - Functions
    
    static func storeCurrentUser(_ user: UserModel) throws {
        try self.getStorage().setObject(user, forKey: currentUserKey)
    }
    
    static func getCurrentUser(withFallbackPolicy policy: FallbackPolicy = .none, completion: @escaping CacheUserCompletion) {
        do {
            let user = try self.getStorage().object(ofType: UserModel.self, forKey: currentUserKey)
            completion(user, nil)
            
        } catch {
            switch policy {
                
            case .none:
                completion(nil, error)
                
            case .network(let controller):
                controller.showSpinner()
                SHOAPIClient.shared.getMe() { object, error, code in
                    controller.dismissSpinner()
                    completion(object as? UserModel, error)
                }
            }
        }
    }
    
    static func storeUser(_ user: UserModel, withId id: Int64) throws {
        let key = String(format: userKey, arguments: [id])
        try self.getStorage().setObject(user, forKey: key)
    }
    
    static func getUserWithId(_ id: Int64) -> UserModel? {
        let key = String(format: userKey, arguments: [id])
        return try? self.getStorage().object(ofType: UserModel.self, forKey: key)
    }
    
    static func storeConfigurations(_ configs: ConfigurationsModel) throws {
        try self.getStorage().setObject(configs, forKey: configurationsKey)
    }
    
    static func getConfigurations() throws -> ConfigurationsModel {
        return try self.getStorage().object(ofType: ConfigurationsModel.self, forKey: configurationsKey)
    }
    
    static func storePendingShareEventId(_ eventId: Int64) throws {
        try self.getStorage().setObject(eventId, forKey: pendingShareEventId, expiry: Expiry.seconds(60*60))
    }
    
    static func getPendingShareEventId() throws -> Int64 {
        return try self.getStorage().object(ofType: Int64.self, forKey: pendingShareEventId)
    }
    
    static func removedPendingShareEventId() throws {
        try self.getStorage().removeObject(forKey: pendingShareEventId)
    }
    
    static func storeContacts(_ contacts: [ContactModel]) throws {
        do {
            if let serializedContacts = try? JSONEncoder().encode(contacts) {
                try self.getStorage().setObject(serializedContacts, forKey: contactsKey)
            }
        } catch {
            print(error)
        }
    }

    static func getContacts() throws -> [ContactModel]? {
        let serialisedContacts =  try self.getStorage().object(ofType: Data.self, forKey: contactsKey)
        return try? JSONDecoder().decode([ContactModel].self, from: serialisedContacts)
    }

    static func storeFeedItems(_ items: [FeedItemModel]) throws -> Error? {
        do {
            let topItemsSlice = items.prefix(20)
            let topItems = Array(topItemsSlice)
            
            if let serializedFeed = try? JSONEncoder().encode(topItems) {
                try self.getStorage().setObject(serializedFeed, forKey: feedItemsKey)
            }
            
            return nil
        } catch {
            return error
        }
    }
    
    static func getFeedItems() throws -> [FeedItemModel]? {
        let serializedFeed =  try self.getStorage().object(ofType: Data.self, forKey: feedItemsKey)
        return try? JSONDecoder().decode([FeedItemModel].self, from: serializedFeed)
    }

    static func storeFeatureFeed(_ items: [FeaturedSectionModel]) throws -> Error? {
        do {
            let feedSlice = items.prefix(20)
            let topFeed = Array(feedSlice)
            
            if let serializedFeed = try? JSONEncoder().encode(topFeed) {
                try self.getStorage().setObject(serializedFeed, forKey: featuredFetchKey)
            }
            
            return nil
        } catch {
            return error
        }
    }
    
    static func getFeatureFeedItems() throws -> [FeaturedSectionModel]? {
        let serialisedContacts =  try self.getStorage().object(ofType: Data.self, forKey: featuredFetchKey)
        return try? JSONDecoder().decode([FeaturedSectionModel].self, from: serialisedContacts)
    }
    
    static func storeConversations(_ conversations: [Conversation]) throws -> Error? {
        do {
            let conversationsSlice = conversations.prefix(20)
            let topConversations = Array(conversationsSlice)

            if let serializedConversations = try? JSONEncoder().encode(topConversations) {
                try self.getStorage().setObject(serializedConversations, forKey: conversationsListKey)
            }
            
            return nil
        } catch {
            return error
        }
    }
    
    static func getConversations() throws -> [Conversation]? {
        let serialisedConversations =  try self.getStorage().object(ofType: Data.self, forKey: conversationsListKey)
        return try? JSONDecoder().decode([Conversation].self, from: serialisedConversations)
    }
    
    static func storeNotifications(_ notifications: [NotificationModel]) throws -> Error? {
        do {
            let notificationsSlice = notifications.prefix(20)
            let topNotifications = Array(notificationsSlice)
            
            if let serializedNotifications = try? JSONEncoder().encode(topNotifications) {
                try self.getStorage().setObject(serializedNotifications, forKey: notificationsListKey)
            }
            
            return nil
        } catch {
            return error
        }   
    }
    
    static func getNotifications() throws -> [NotificationModel]? {
        let serializedNotifications =  try self.getStorage().object(ofType: Data.self, forKey: notificationsListKey)
        return try? JSONDecoder().decode([NotificationModel].self, from: serializedNotifications)
    }
}
