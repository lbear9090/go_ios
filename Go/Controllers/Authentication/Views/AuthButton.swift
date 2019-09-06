//
//  AuthButton.swift
//  Go
//
//  Created by Lucky on 01/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class AuthButton: UIButton {
        
    convenience init() {
        self.init(with: .auth)
        self.isEnabled = false
    }
    
    open override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.backgroundColor = .green
            } else {
                self.backgroundColor = .gray
            }
        }
    }
    
}
