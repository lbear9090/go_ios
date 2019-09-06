//
//  EventsFriendsAttendingDataProvider.swift
//  Go
//
//  Created by Lucky on 15/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import IGListKit

class EventsFriendsAttendingDataProvider: FeedDataProvider {

    let profileSegmentedControlType: ProfileSegmentedControlType
    let userEndpointType: UserEndpointType

    init(withSegmentType selectedSegmentType: ProfileSegmentedControlType, endpointType: UserEndpointType) {
        self.profileSegmentedControlType = selectedSegmentType
        self.userEndpointType = endpointType
    }
    
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping FeedDataRequestClosure) {
        SHOAPIClient.shared.getEvents(withScope: self.profileSegmentedControlType,
                                      for: self.userEndpointType,
                                      friendsAttending: true,
                                      offset: request.offset,
                                      limit: request.limit) { object, error, code in
                                        let eventsWrapper = object as? ProfileEventsModel
                                        completionHandler(eventsWrapper?.events, error)
        }
    }
}
