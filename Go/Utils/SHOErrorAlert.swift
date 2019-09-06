//
//  ErrorAlert.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 22/09/2017.
//
//

import Foundation
import UIKit

public protocol SHOErrorAlert {
    func showErrorAlertWith(message: String?, completion: (() -> Void)?)
}

extension UIViewController: SHOErrorAlert {
    
    public func showErrorAlertWith(message: String?, completion: (() -> Void)? = nil) {
        let action: UIAlertAction = UIViewController.okAction { _ in
            completion?()
        }
        
        let alert = UIViewController.alertWith(title:"ERROR_ALERT_TITLE".localized,
                                            message: message,
                                            actions: [action])
        
        
        if let presentedVC = self.presentedViewController {
            presentedVC.present(alert,
                                animated: true,
                                completion: nil)
        }
        else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

