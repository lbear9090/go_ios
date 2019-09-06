//
//  Attachment.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import Marshal

enum AttachmentType: String, Codable {
    case image
    case location
    case video
    case UNKNOWN
}

struct Attachment: Unmarshaling, Marshaling, Codable {
    var id: Int64
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var imageAttachment: ImageAttachment?
    var locationAttachment: LocationAttachment?
    var videoAttachment: VideoAttachment?
    var type: AttachmentType
    
    public init(object: MarshaledObject) throws {
        id =                              try object <| "id"
        createdAt =                     (try? object <| "created_at") ?? Date().timeIntervalSince1970
        updatedAt =                     (try? object <| "updated_at") ?? Date().timeIntervalSince1970
        imageAttachment =                try? object <| "attachment"
        locationAttachment =             try? object <| "attachment"
        videoAttachment =                try? object <| "attachment"
        type = AttachmentType(rawValue: (try? object <| "type") ?? "UNKNOWN") ?? .UNKNOWN
    }
    
    public init(id: Int64 = 0, imageAttachment: ImageAttachment? = nil, locationAttachment: LocationAttachment? = nil, videoAttachment: VideoAttachment? = nil, createdAt: TimeInterval = Date().timeIntervalSinceReferenceDate, updatedAt: TimeInterval = Date().timeIntervalSinceReferenceDate) {
        self.id = id
        self.imageAttachment = imageAttachment
        self.locationAttachment = locationAttachment
        self.videoAttachment = videoAttachment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        if self.imageAttachment != nil {
            self.type = .image
        }
        else if self.locationAttachment != nil {
            self.type = .location
        }
        else if self.videoAttachment != nil {
            self.type = .video
        }
        else {
            self.type = .UNKNOWN
        }
    }
    
    func marshaled() -> [String: Any] {
        var obj:[String: Any] = [:]
        
        obj["type"] = self.type.rawValue
        
        if self.imageAttachment != nil {
            obj["image"] = self.imageAttachment?.marshaled()
        }
        
        if self.locationAttachment != nil {
            obj["location"] = self.locationAttachment?.marshaled()
        }
        
        if self.videoAttachment != nil {
            obj["video"] = self.videoAttachment?.marshaled()
        }
        
        return obj
    }
}

struct ImageAttachment: Unmarshaling, Marshaling, Codable {
    var id: Int64
    var images: ImagesModel
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var type: AttachmentType
    
    public init(object: MarshaledObject) throws {
        id =                              try object <| "id"
        type =                          (try? object <| "status") ?? .UNKNOWN
        createdAt =                     (try? object <| "created_at") ?? Date().timeIntervalSince1970
        updatedAt =                     (try? object <| "updated_at") ?? Date().timeIntervalSince1970
        images =                          try object <| "images"
    }
    
    public init(id: Int64 = 0, imageURL: URL, createdAt: TimeInterval = Date().timeIntervalSinceReferenceDate, updatedAt: TimeInterval = Date().timeIntervalSinceReferenceDate) {
        self.id = id
        self.images = ImagesModel(imageURL: imageURL.absoluteString)
        self.type = .image
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func marshaled() -> [String: Any] {
        var obj:[String: Any] = [:]
        
        obj["image_url"] = self.images.originalUrl
        
        return obj
    }
}

struct LocationAttachment: Unmarshaling, Marshaling, Codable {
    var id: Int64
    var lat: Double
    var lon: Double
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var type: AttachmentType
    
    public init(object: MarshaledObject) throws {
        id =                              try object <| "id"
        lat =                             try object <| "coordinates.latitude"
        lon =                             try object <| "coordinates.longitude"
        type =                          (try? object <| "status") ?? .UNKNOWN
        createdAt =                     (try? object <| "created_at") ?? Date().timeIntervalSince1970
        updatedAt =                     (try? object <| "updated_at") ?? Date().timeIntervalSince1970
    }
    
    public init(id: Int64 = 0, latitude: Double, longitude: Double, createdAt: TimeInterval = Date().timeIntervalSinceReferenceDate, updatedAt: TimeInterval = Date().timeIntervalSinceReferenceDate) {
        self.id = id
        self.lat = latitude
        self.lon = longitude
        self.type = .location
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func marshaled() -> [String: Any] {
        var obj:[String: Any] = [:]
        
        obj["latitude"] = self.lat
        obj["longitude"] = self.lon
        
        return obj
    }
}

struct VideoAttachment: Unmarshaling, Marshaling, Codable {
    var id: Int64
    var videoURL: URL
    var images: ImagesModel?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var type: AttachmentType
    
    public init(object: MarshaledObject) throws {
        id =                              try object <| "id"
        videoURL =                        try object <| "videos.original_url"
        images =                        (try? object <| "images")
        type =                          (try? object <| "status") ?? .UNKNOWN
        createdAt =                     (try? object <| "created_at") ?? Date().timeIntervalSince1970
        updatedAt =                     (try? object <| "updated_at") ?? Date().timeIntervalSince1970
    }
    
    public init(id: Int64 = 0, videoURL: URL, createdAt: TimeInterval = Date().timeIntervalSinceReferenceDate, updatedAt: TimeInterval = Date().timeIntervalSinceReferenceDate) {
        self.id = id
        self.videoURL = videoURL
        self.type = .video
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func marshaled() -> [String: Any] {
        var obj:[String: Any] = [:]
        
        obj["video_url"] = self.videoURL.absoluteString
        
        return obj
    }
}
