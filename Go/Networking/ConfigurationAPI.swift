//
//  ConfigurationAPI.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func configuration(with completionHandler: @escaping ParsingCompletionHandler) {
        
        self.loadGETRequest(urlString: APIEndpoints.configurations.versioned,
                            type: ConfigurationsModel.self,
                            key: APIKeys.configuration) { (data, error, statusCode) in
                                
                                if let configurations = data as? ConfigurationsModel {
                                    try? CacheManager.storeConfigurations(configurations)
                                }
                                
                                completionHandler(data, error, statusCode)
        }
    }
    
}
