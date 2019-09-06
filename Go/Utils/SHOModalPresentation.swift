//
//  SHOModalPresentation.swift
//  Go
//
//  Created by Lucky on 02/11/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

public protocol SHOModalPresentation {
    func isModal() -> Bool
    func dismissModal()
}

extension UIViewController: SHOModalPresentation {
    public func isModal() -> Bool {
        if self.presentingViewController?.presentedViewController == self {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController ==
            self.navigationController && self.navigationController?.viewControllers.first == self {
            return true
        }
        
        if let _ = self.tabBarController?.presentingViewController?.isKind(of: UITabBarController.self) {
            return true
        }
        
        return false
    }
    
    @objc public func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
}
