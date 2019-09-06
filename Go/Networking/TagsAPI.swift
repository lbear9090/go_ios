//
//  TagsAPI.swift
//  Go
//
//  Created by Lucky on 26/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func tags(limit: Int, offset: Int, completionHandler: @escaping ParsingCompletionHandler) {
        
        let params = [APIKeys.limit: limit,
                      APIKeys.offset: offset]
        
        self.loadGETRequest(urlString: APIEndpoints.tags.versioned,
                            parameters: params,
                            type: TagModel.self,
                            key: APIKeys.tags,
                            completionHandler: completionHandler)
    }
    
    func events(forTag tag: String, from offset: Int, to limit: Int, completionHandler: @escaping ParsingCompletionHandler) {
        let params = [APIKeys.limit: limit,
                      APIKeys.offset: offset]
        
        let endpoint = String(format: APIEndpoints.tagEvents, tag)
        
        self.loadGETRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: EventModel.self,
                            key: APIKeys.events,
                            completionHandler: completionHandler)
    }
    
}
