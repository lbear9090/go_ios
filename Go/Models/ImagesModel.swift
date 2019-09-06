//
//  ImagesModel.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

struct ImagesModel: Unmarshaling, Codable {
    var smallUrl: String?
    var mediumUrl: String?
    var largeUrl: String?
    var originalUrl: String?
    var sharingUrl: String?
    
    public init(object: MarshaledObject) throws {
        smallUrl =      try object <| "small_url"
        mediumUrl =     try object <| "medium_url"
        largeUrl =      try object <| "large_url"
        originalUrl =   try object <| "original_url"
        sharingUrl =    try object <| "sharing_url"
    }
    
    public init(imageURL: String) {
        self.smallUrl = imageURL
        self.mediumUrl = imageURL
        self.largeUrl = imageURL
        self.originalUrl = imageURL
    }
}

extension ImagesModel: Marshaling {
    func marshaled() -> [String: Any] {
        var obj: [String: Any] = [:]
        
        obj["small_url"] = self.smallUrl
        obj["medium_url"] = self.mediumUrl
        obj["large_url"] = self.largeUrl
        obj["original_url"] = self.originalUrl
        
        return obj
    }
}
