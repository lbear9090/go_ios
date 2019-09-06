//
//  TagEventsDataProvider.swift
//  Go
//
//  Created by Lucky on 29/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation

class TagEventsDataProvider: FeedDataProvider {
    
    let tag: String
    
    init(withTag tag: String) {
        self.tag = tag
    }
    
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping FeedDataRequestClosure) {
        SHOAPIClient.shared.events(forTag: self.tag, from: request.offset, to: request.limit) { (object, error, code) in
            if let events = object as? [EventModel] {
                completionHandler(events, error)
            } else {
                completionHandler(nil, error)
            }
        }
    }
}
