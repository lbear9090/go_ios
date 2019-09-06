//
//  IdNameModel.swift
//  Go
//
//  Created by Lucky on 14/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class IdNameModel: Unmarshaling, Codable {
    var id: Int64
    var name: String

    required init(object: MarshaledObject) throws {
        id =    try object <| "id"
        name =  try object <| "name"
    }
}

extension IdNameModel: PickerValue {
    var pickerValue: String {
        return self.name
    }
}
