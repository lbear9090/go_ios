//
//  FriendsFeedDataProvider.swift
//  Go
//
//  Created by Lucky on 20/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import IGListKit

class FriendsFeedMapDataProvider: FeedDataProvider, MapDataProvider {
    
    var emptyStateString: String {
        return "FRIENDS_EMPTY_STATE".localized
    }
    
    
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping FeedDataRequestClosure) {
        self.getMapItemsWithRequest(request) { (events, error) in
            completionHandler(events, error)
        }
    }
    
    func getMapItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping MapDataRequestClosure) {
        SHOAPIClient.shared.getFriendsFeed(with: request) { (object, error, code) in
            if let events = object as? [EventModel] {
                completionHandler(events, error)
            } else {
                completionHandler(nil, error)
            }
        }
    }
}
