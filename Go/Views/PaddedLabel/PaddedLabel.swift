//
//  PaddedLabel.swift
//  Go
//
//  Created by Lucky on 13/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
    
    var topInset = CGFloat(0.0)
    var bottomInset = CGFloat(0.0)
    var leftInset = CGFloat(10.0)
    var rightInset = CGFloat(10.0)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        
    }
    
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
