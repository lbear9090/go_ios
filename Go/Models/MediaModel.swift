//
//  MediaModel.swift
//  Go
//
//  Created by Lucky on 28/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

enum MediaType: String, Codable {
    case image
    case video
    case text
}

class MediaModel: Unmarshaling, Codable {
    var id: Int64
    var type: MediaType
    var images: ImagesModel?
    var videoUrl: String?
    var text: String?
    
    required init(object: MarshaledObject) throws {
        id =        try object <| "id"
        type =      try object <| "type"
        images =    try? object <| "images"
        videoUrl =  try? object <| "videos.original_url"
        text =      try? object <| "text"
    }
}
