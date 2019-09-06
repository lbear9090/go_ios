//
//  UINavigationBar+Appearance.swift
//  Go
//
//  Created by Lucky on 02/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

public extension UINavigationBar {
    
    public func setBackgroundTransparent() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.isTranslucent = true
        self.backgroundColor = .clear
        self.shadowImage = UIImage()
    }
}
