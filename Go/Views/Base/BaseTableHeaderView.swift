//
//  BaseTableHeaderView.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class BaseTableHeaderView: SHOView {
    
    public func autoresize(for size: CGSize) {
        let widthConstraint = NSLayoutConstraint.init(item: self,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .width,
                                                      multiplier: 1.0,
                                                      constant: size.width)
        self.addConstraint(widthConstraint)
        
        let height = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        self.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: height)
    }
}
