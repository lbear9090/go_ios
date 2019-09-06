//
//  LocationEventsDataProvider.swift
//  Go
//
//  Created by Lucky on 28/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation

class LocationEventsDataProvider: FeedDataProvider, MapDataProvider {

    let location: LocationResultModel
    
    init(withLocation location: LocationResultModel) {
        self.location = location
    }
    
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping FeedDataRequestClosure) {
        var request = request
        request.latitude = self.location.latitude
        request.longitude = self.location.longitude

        SHOAPIClient.shared.events(for: request) { (object, error, code) in
            if let events = object as? [EventModel] {
                completionHandler(events, error)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func getMapItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping MapDataRequestClosure) {
        SHOAPIClient.shared.events(for: request) { (object, error, code) in
            if let events = object as? [EventModel] {
                completionHandler(events, error)
            } else {
                completionHandler(nil, error)
            }
        }
    }
}
