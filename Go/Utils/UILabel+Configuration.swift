//
//  UILabel+Configuration.swift
//  Go
//
//  Created by Lee Whelan on 01/11/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    convenience init(with config: LabelConfig) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setConfig(config)
    }
    
    func setConfig(_ config: LabelConfig) {
        self.numberOfLines = config.numberOfLines
        self.textAlignment = config.textAlignment
        self.backgroundColor = config.backgroundColor
        self.textColor = config.textColor
        self.font = config.textFont
        self.text = config.text
    }
    
}

struct LabelConfig {
    let backgroundColor: UIColor
    let textColor: UIColor
    let textFont: UIFont
    let numberOfLines: Int
    let textAlignment: NSTextAlignment
    let text: String
    
    public init(textFont: UIFont,
         text: String = "",
         textAlignment: NSTextAlignment = .left,
         textColor: UIColor = .white,
         backgroundColor: UIColor = .clear,
         numberOfLines: Int = 1) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.textFont = textFont
        self.text = text
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
    }
}
