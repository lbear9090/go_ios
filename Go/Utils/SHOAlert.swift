//
//  SHOAlert.swift
//  Go
//
//  Created by Lucky on 17/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

public protocol SHOAlertFactory {
    typealias AlertActionHandler = ((UIAlertAction) -> Void)?
    
    static func alertWith(title: String, message: String) -> UIAlertController
    
    static func actionSheetWith(title: String, message: String) -> UIAlertController
    
    static func alertWith(title: String?, message: String?, actions: [UIAlertAction]?) -> UIAlertController
    
    static func actionSheetWith(title: String?, message: String?, actions: [UIAlertAction]?) -> UIAlertController?
}

extension UIViewController: SHOAlertFactory {
    public static func alertWith(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    public static func actionSheetWith(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    }
    
    public static func alertWith(title: String?, message: String?, actions: [UIAlertAction]?) -> UIAlertController {
        let controller = self.alertWith(title: title ?? "", message: message ?? "")
        
        if let actions = actions {
            actions.forEach { controller.addAction($0) }
        } else {
            controller.addAction(self.dismissAction())
        }
        
        return controller
    }
    
    public static func actionSheetWith(title: String?, message: String?, actions: [UIAlertAction]?) -> UIAlertController? {
        guard let actions = actions else {
            return nil
        }
        
        let controller = self.actionSheetWith(title: title ?? "", message: message ?? "")
        
        actions.forEach { controller.addAction($0) }
        
        return controller
    }
}

// MARK: - Actions

extension UIViewController {
    
    public static func okAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: handler)
    }
    
    public static func cancelAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: handler)
    }
    
    public static func dismissAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: handler)
    }
    
    public static func deleteAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: handler)
    }
    
    public static func yesAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: handler)
    }
    
    public static func noAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: handler)
    }
    
    public static func retryAction(withHandler handler: AlertActionHandler = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default, handler: handler)
    }
    
}

