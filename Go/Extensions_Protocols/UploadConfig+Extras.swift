//
//  UploadConfig+Extras.swift
//  Go
//
//  Created by Killian Kenny on 12/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation

extension UploadConfig {
        
    public static func coverImage(email: String) -> UploadConfig {
        return UploadConfig(fileName: "user_cover_\(email)_\(Int(Date().timeIntervalSince1970))",
            directoryPath: "user_cover_direct_upload/")
    }
    
    public static func identification(userId: Int64) -> UploadConfig {
        return UploadConfig(fileName: "identification_\(userId)_\(Int(Date().timeIntervalSince1970))",
            directoryPath: "identification_direct_upload/")
    }
    
    public static func eventMedia() -> UploadConfig {
        return UploadConfig(fileName: "event_media_\(Int(Date().timeIntervalSince1970))",
            directoryPath: "event_media_items/")
    }
    
    public static func timelineMedia(eventId: Int64) -> UploadConfig {
        return UploadConfig(fileName: "timeline_media_\(eventId)_\(Int(Date().timeIntervalSince1970))",
            directoryPath: "timeline_media_items/")
    }
    
    public static func chatAttachment(userID: Int64?) -> UploadConfig {
        return UploadConfig(fileName: "message_attachment_\(userID ?? Int64(arc4random_uniform(9999)))_\(Int(Date().timeIntervalSince1970))",
            directoryPath: "direct_message_attachment_upload/")
    }
    
}
