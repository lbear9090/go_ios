//
//  Status.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import UIKit

enum MessageStatus: String, Codable {
    case pending
    case sending
    case sent
    case delivered
    case read
    case failed
    case UNKNOWN
    
    var icon: UIImage {
        switch self {
        case .pending, .sending, .sent:
            return .chatDeliveredStatus
        case .read, .delivered:
            return .chatSeenStatus
        case .failed:
            return .chatFailedStatus
        default:
            return UIImage()
        }
    }
}

struct Status {
    var int: Int64
    var recipient: Participant
    var status: MessageStatus
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
}
