//
//  UIScrollView+Keyboard.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 20/09/2017.
//
//

import Foundation
import UIKit

public extension UIScrollView {
    
    public func setContentInsetsForKeyboard(with frame: CGRect) {
        let bottomInset = frame.size.height
        
        self.contentInset.bottom = bottomInset
        self.scrollIndicatorInsets.bottom = bottomInset
        self.layoutIfNeeded()
    }
    
}
