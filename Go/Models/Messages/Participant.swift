//
//  Owner.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import Marshal

struct Participant: Unmarshaling, Codable {
    var id: Int64
    var muted: Bool
    var instance: UserModel
    
    init(object: MarshaledObject) throws {
        id = try object <| "id"
        muted = (try? object <| "muted") ?? false
        instance = try object <| "instance"
    }
}
