//
//  TagModel.swift
//  Go
//
//  Created by Lucky on 26/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class TagModel: Unmarshaling, Codable {
    var id: Int
    var text: String
    var count: Int
    
    required init(object: MarshaledObject) throws {
        id =    try object <| "id"
        text =  try object <| "text"
        count =  try object <| "count"
    }
}
