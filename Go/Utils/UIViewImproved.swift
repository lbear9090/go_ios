//
//  UINavigationBar+Appearance.swift
//  Go
//
//  Created by Lucky on 02/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public static func newAutoLayout<T: UIView>() -> T {
        let view = T()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
