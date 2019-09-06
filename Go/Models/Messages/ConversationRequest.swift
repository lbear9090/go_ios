//
//  ConversationRequest.swift
//  Go
//
//  Created by Lucky on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import Marshal

class ConversationRequest: Marshaling {
    var name: String
    var imageURL: String?
    var message: Message?
    var participants: [UserModel]
    
    public init(name: String, imageURL: String? = nil, message: Message? = nil, participants: [UserModel]) {
        self.name = name
        self.imageURL = imageURL
        self.message = message
        self.participants = participants
    }
    
    func marshaled() -> [String: Any] {
        var obj:[String: Any] = [:]
        
        var metadata: [String: Any] = ["name": self.name]
        metadata["image_url"] = self.imageURL
        
        obj["meta_data"] = metadata
        obj["message"] = self.message?.marshaled()
        
        var marshaledParticipants: [[String: Any]] = []
        
        for participant in self.participants {
            marshaledParticipants.append(["id": participant.userId, "type": "User"])
        }
        
        obj["participants"] = marshaledParticipants
        
        
        return obj
    }
}
