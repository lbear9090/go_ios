//
//  FeedAPI.swift
//  Go
//
//  Created by Lucky on 16/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func getFeed(from offset: Int, to limit: Int, with completionHandler: @escaping ParsingCompletionHandler) {
        
        let params: [String: Any] = [APIKeys.offset: offset,
                                     APIKeys.limit: limit]
        
        self.loadGETRequest(urlString: APIEndpoints.feed.versioned,
                            parameters: params,
                            type: FeedItemModel.self,
                            key: APIKeys.feed,
                            completionHandler: completionHandler)
    
    }
    
    func getFeaturedFeed(with request: FeedDataRequestModel, completionHandler: @escaping ParsingCompletionHandler) {
            self.loadPOSTRequest(urlString: APIEndpoints.featuredFeed.versioned,
                                 parameters: request.marshaled(),
                                 type: FeaturedFetchModel.self,
                                 completionHandler: completionHandler)
    
    }
    
    func getFriendsFeed(with request: FeedDataRequestModel, completionHandler: @escaping ParsingCompletionHandler) {
        
        self.loadPOSTRequest(urlString: APIEndpoints.friendsFeed.versioned,
                             parameters: request.marshaled(),
                             type: EventModel.self,
                             key: APIKeys.events,
                             completionHandler: completionHandler)
    }
    
    func getGroupsFeed(with request: FeedDataRequestModel, completionHandler: @escaping ParsingCompletionHandler) {
        
        self.loadPOSTRequest(urlString: APIEndpoints.groupsFeed.versioned,
                             parameters: request.marshaled(),
                             type: EventModel.self,
                             key: APIKeys.events,
                             completionHandler: completionHandler)
    }
    
}
