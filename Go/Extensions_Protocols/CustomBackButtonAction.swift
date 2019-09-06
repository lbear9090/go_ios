//
//  CustomBackButtonAction.swift
//  Go
//
//  Created by Nouman Tariq on 15/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

// MARK: - Overriding Back Button Behaviour

protocol CustomBackButton {
    func backButtonPressed()
    func showUnsavedChangesWarning(_ message: String)
    
    var unsavedChanges: Bool { get }
}

extension CustomBackButton where Self: UIViewController {
    
    func backButtonPressed() {
        if self.unsavedChanges {
            self.showUnsavedChangesWarning()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showUnsavedChangesWarning(_ message: String = "UNCOMMITED_CHANGES_MESSAGE".localized) {
        let okAction = UIAlertAction(title: "DISCARD_CHANGES_BUTTON".localized,
                                     style: .destructive) { [unowned self] (action) in
                                        self.navigationController?.popViewController(animated: true)
        }
        
        let dismissAction = UIViewController.cancelAction()
        
        let alert = SHOViewController.alertWith(title: "UNCOMMITED_CHANGES_TITLE".localized,
                                                message: message,
                                                actions: [okAction, dismissAction])
        self.present(alert, animated: true, completion: nil)
    }
}
