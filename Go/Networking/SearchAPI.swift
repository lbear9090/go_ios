//
//  SearchAPI.swift
//  Go
//
//  Created by Lucky on 22/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func locations(for term: String? = nil, latitude: Double? = nil, longitude: Double? = nil, completionHandler: @escaping ParsingCompletionHandler) {
        
        var searchParams = [String: Any]()
        searchParams[APIKeys.term] = term
        searchParams[APIKeys.latitude] = latitude
        searchParams[APIKeys.longitude] = longitude
        
        if searchParams.isEmpty {
            return
        }
        
        let params = [APIKeys.search: searchParams]
        
        self.loadPOSTRequest(urlString: APIEndpoints.locationSearch.versioned,
                             parameters: params,
                             type: LocationResultModel.self,
                             key: APIKeys.locations,
                             completionHandler: completionHandler)
    }
    
    func users(forTerm term: String? = nil, from offset: Int? = nil, to limit: Int? = nil, completionHandler: @escaping ParsingCompletionHandler) {
        var params: [String: Any] = [:]
        params[APIKeys.search] = [APIKeys.term: term]
        params[APIKeys.offset] = offset
        params[APIKeys.limit] = limit
        
        self.loadPOSTRequest(urlString: APIEndpoints.userSearch.versioned,
                             parameters: params,
                             type: UserModel.self,
                             key: APIKeys.users,
                             completionHandler: completionHandler)
    }
    
    func tags(forTerm term: String? = nil, from offset: Int? = nil, to limit: Int? = nil, completionHandler: @escaping ParsingCompletionHandler) {
        
        var params: [String: Any] = [:]
        params[APIKeys.search] = [APIKeys.term: term]
        params[APIKeys.offset] = offset
        params[APIKeys.limit] = limit
        
        self.loadPOSTRequest(urlString: APIEndpoints.tagSearch.versioned,
                             parameters: params,
                             type: TagModel.self,
                             key: APIKeys.tags,
                             completionHandler: completionHandler)
    }
    
    func address(forLatitude latitude: Double, longitude: Double, completionHandler: @escaping ParsingCompletionHandler) {
        let params = [APIKeys.search: [APIKeys.latitude: latitude,
                                       APIKeys.longitude: longitude]]

        self.loadPOSTRequest(urlString: APIEndpoints.addressSearch.versioned,
                             parameters: params,
                             type: AddressSearchResultModel.self,
                             key: APIKeys.location,
                             completionHandler: completionHandler)
    }
    
}

