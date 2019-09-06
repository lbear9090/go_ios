//
//  UIImageView+Convenience.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 20/09/2017.
//
//

import Foundation
import UIKit

public extension UIImageView {
    
    public func makeCircular(_ contentMode: UIViewContentMode? = nil) {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
        if let contentMode = contentMode {
            self.contentMode = contentMode
        }
    }
    
}
