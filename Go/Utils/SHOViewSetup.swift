//
//  ViewSetup.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 21/09/2017.
//
//

import Foundation
import UIKit

public protocol SHOViewSetup {
    func setup()
    func applyConstraints()
}

extension UIView: SHOViewSetup {
    @objc open func setup() { }
    @objc open func applyConstraints() { }
}
