//
//  MessageInputBar+Defaults.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

extension MessageInputBar {
        
    var text: String {
        return self.inputTextView.text
    }
    
    func resignKeyboard(clearText: Bool = true) {
        self.inputTextView.resignFirstResponder()
        if clearText {
            self.clearText()
        }
    }
    
    func clearText() {
        self.inputTextView.text = ""
        self.textViewDidChange()
    }
    
}
