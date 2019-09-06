//
//  ResponseMessageModel.swift
//  Go
//
//  Created by Lucky on 09/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class ResponseMessageModel: Unmarshaling {

    let message: String

    required init(object: MarshaledObject) throws {
        message = (try? object <| "message") ?? ""
    }
    
}
