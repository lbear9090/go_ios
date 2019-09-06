//
//  ButtonConfig+Customizations.swift
//  Go
//
//  Created by Killian Kenny on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import SHOSwiftUtils

extension ButtonConfig {
    
    static var auth: ButtonConfig {
        return ButtonConfig(textLabelColor: .text,
                            textLabelFont: Font.semibold.withSize(.large),
                            backgroundColor: .white,
                            cornerRadius: CornerRadius.small.rawValue,
                            borderWidth: 1.0,
                            borderColor: .white)
    }
}
