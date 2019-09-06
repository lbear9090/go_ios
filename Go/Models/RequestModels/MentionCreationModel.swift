//
//  MentionCreationModel.swift
//  Go
//
//  Created by Lucky on 04/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import SZMentionsSwift

struct MentionCreationModel: CreateMention {
    var mentionName: String
    var mentionRange: NSRange = NSRange(location: 0, length: 0)
    
    init(text: String) {
        self.mentionName = text
    }
}
