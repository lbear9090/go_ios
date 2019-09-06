//
//  FriendsAPI.swift
//  Go
//
//  Created by Lucky on 23/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func createFriendRequest(forUserId userId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.friendRequest, userId)
        
        self.loadPOSTRequest(urlString: endpoint.versioned,
                             type: FriendRequestModel.self,
                             key: APIKeys.request,
                             completionHandler: completionHandler)
    }
    
    func deleteFriendRequest(withId requestId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.cancelFriendRequest, requestId)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
    func acceptFriendRequest(withId requestId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.acceptFriendRequst, requestId)

        self.loadPUTRequest(urlString: endpoint.versioned,
                            type: TypePlaceholder.self,
                            completionHandler: completionHandler)
    }
    
    func rejectFriendRequest(withId requestId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.rejectFriendRequst, requestId)

        self.loadDELETERequest(urlString: endpoint.versioned,
                            type: TypePlaceholder.self,
                            completionHandler: completionHandler)
    }
    
    func removeFriend(withId userId: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        let endpoint = String(format: APIEndpoints.friends, userId)
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: TypePlaceholder.self,
                               completionHandler: completionHandler)
    }
    
}
