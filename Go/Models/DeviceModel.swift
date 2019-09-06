//
//  DeviceModel.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class DeviceModel: Unmarshaling {
    
    var deviceId: Int
    var platform: String
    var uuid: String
    var pushToken: String
    var endpointArn: String
    var active: Bool
    
    required init(object: MarshaledObject) throws {
        deviceId =      try object <| "id"
        platform =      try object <| "platform"
        uuid =          try object <| "uuid"
        pushToken =     try object <| "push_token"
        endpointArn =   try object <| "endpoint_arn"
        active =        try object <| "active"
    }
}
