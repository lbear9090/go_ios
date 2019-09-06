//
//  UINavigationControllerExtension.swift
//  Go
//
//  Created by Nouman Tariq on 04/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? UIApplication.shared.statusBarStyle
    }
    
    override open var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .portrait
    }
}
