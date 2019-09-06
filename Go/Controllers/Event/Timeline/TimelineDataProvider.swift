//
//  TimelineDataProvider.swift
//  Go
//
//  Created by Lucky on 21/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import IGListKit

class TimelineDataProvider: FeedDataProvider {

    var emptyStateString: String {
        return "TIMELINE_EMPTY_STATE".localized
    }
    
    let eventId: Int64
    
    init(eventId: Int64) {
        self.eventId = eventId
    }
    
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping FeedDataRequestClosure) {
        SHOAPIClient.shared.getTimeline(for: self.eventId,
                                        limit: request.limit,
                                        offset: request.offset) { object, error, code in
                                            if let items = object as? [FeedItemModel] {
                                                let timelines = items.compactMap { feedItem -> TimelineModel? in
                                                    return feedItem.timelineItem
                                                }
                                                completionHandler(timelines, error)
                                            } else {
                                                completionHandler(nil, error)
                                            }
        }
    }
}
