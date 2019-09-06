//
//  Message.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import MessageKit
import MapKit
import Kingfisher
import Marshal

struct Message: Unmarshaling, Codable {
    var id: Int64 = 0
    var text: String = ""
    var owner: Participant
    var attachments: [Attachment] = []
    var status: MessageStatus
    var createdAt: TimeInterval = 0
    var updatedAt: TimeInterval = 0
    
    public init(object: MarshaledObject) throws {
        id =                               try object <| "id"
        text =                           (try? object <| "text") ?? ""
        owner =                            try object <| "owner"
        createdAt =                      (try? object <| "created_at") ?? Date().timeIntervalSince1970
        updatedAt =                      (try? object <| "updated_at") ?? Date().timeIntervalSince1970
        attachments =                    (try? object <| "attachments") ?? []
        status =                         (try? object <| "status") ?? .UNKNOWN
    }
    
    public init(id: Int64 = 0, text: String = "", owner: Participant, attachments: [Attachment] = [], status: MessageStatus = .sending, createdAt: TimeInterval = Date().timeIntervalSinceReferenceDate, updatedAt: TimeInterval = Date().timeIntervalSinceReferenceDate) {
        self.id = id
        self.text = text
        self.owner = owner
        self.attachments = attachments
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


extension Message: MessageType {
    
    var sender: Sender {
        return Sender(id:"\(self.owner.id)", displayName:self.owner.instance.displayName)
    }
    
    var messageId: String {
        return "\(self.id)"
    }
    
    var sentDate: Date {
        return Date(timeIntervalSince1970: self.createdAt)
    }
    
    var data: MessageData {
        
        if let attachmentType = self.attachments.first?.type {
            switch attachmentType {
            case .image:
                return .photo(UIImage())
            case .location:
                if let location = self.attachments.first?.locationAttachment {
                    return .location(CLLocation(latitude: location.lat, longitude: location.lon))
                }
            case .video:
                if let video = self.attachments.first?.videoAttachment {
                    return .video(file: video.videoURL, thumbnail: UIImage())
                }
            default:
                return .text(self.text)
            }
        }
        
        return .text(self.text)
    }
    
}

extension Message: Marshaling {
    
    func marshaled() -> [String: Any] {
        var obj:[String: Any] = [:]
        
        obj["text"] = self.text
        
        var marshaledAttachments: [[String: Any]] = []
        
        for attachment in self.attachments {
            marshaledAttachments.append(attachment.marshaled())
        }
        
        if marshaledAttachments.count > 0 {
            obj["attachments"] = marshaledAttachments
        }
        
        return ["message": obj]
    }
}
