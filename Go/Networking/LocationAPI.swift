//
//  LocationAPI.swift
//  Go
//
//  Created by Lucky on 27/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func events(for request: FeedDataRequestModel, completionHandler: @escaping ParsingCompletionHandler) {
        
        self.loadPOSTRequest(urlString: APIEndpoints.locationEvents.versioned,
                             parameters: request.marshaled(),
                             type: EventModel.self,
                             key: APIKeys.events,
                             completionHandler: completionHandler)
    }
    
}
