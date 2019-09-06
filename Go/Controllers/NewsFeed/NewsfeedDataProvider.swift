//
//  NewsfeedDataProvider.swift
//  Go
//
//  Created by Lucky on 16/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import IGListKit

class NewsfeedDataProvider: FeedDataProvider {

    var emptyStateString: String {
        return "NEWSFEED_EMPTY_STATE".localized
    }
    
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping ([ListDiffable]?, Error?) -> Void) {
        SHOAPIClient.shared.getFeed(from: request.offset, to: request.limit) { object, error, code in
            
            if let feedItems = object as? [FeedItemModel] {
                
                if request.offset == 0 {
                    let _ = try? CacheManager.storeFeedItems(feedItems)
                }

                feedItems.forEach({ (item) in
                    if let event = item.event {
                        event.feedContext = item.context
                    } else if let timeline = item.timelineItem {
                        timeline.feedContext = item.context
                    }
                })
                
                completionHandler(feedItems, error)
            }
            else {
                completionHandler(nil, error)
            }
        }
    }

    func getCachedItems(completionHandler: @escaping CachedFeedDataRequestClosure) {
        if let cachedItems = try? CacheManager.getFeedItems(), let items = cachedItems {
            items.forEach({ (item) in
                if let event = item.event {
                    event.feedContext = item.context
                } else if let timeline = item.timelineItem {
                    timeline.feedContext = item.context
                }
            })
            
            completionHandler(items)
        } else {
            completionHandler(nil)
        }
    }
}
