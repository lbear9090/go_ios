//
//  FeaturedItem.swift
//  Go
//
//  Created by Lucky on 03/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

enum FeaturedItemSize: String, Codable {
    case small = "small"
    case medium = "large"
    case large = "medium"
}

enum FeaturedSectionType: String, Codable {
    case leftSmall = "left_small"
    case rightSmall = "right_small"
    case leftMedium = "left_medium"
    case rightMedium = "right_medium"
    case leftLarge = "left_large"
    case rightLarge = "right_large"
}

class FeaturedItemModel: Unmarshaling, Codable {
    
    var size: FeaturedItemSize
    var event: EventModel
    
    required init(object: MarshaledObject) throws {
        size = try object <| "size"
        event = try object <| "object"
    }
    
}

class FeaturedSectionModel: Unmarshaling, Codable {
    var type: FeaturedSectionType
    var items: [FeaturedItemModel]
    
    required init(object: MarshaledObject) throws {
        type = try object <| "type"
        items = try object <| "objects"
    }
}

class FeaturedFetchModel: Unmarshaling, Codable {
    
    var offset: Int
    var sections: [FeaturedSectionModel]
    
    required init(object: MarshaledObject) throws {
        offset = try object <| "meta.offset"
        sections = try object <| "objects"
    }
}
