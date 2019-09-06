//
//  UITextField+Convenience.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 20/09/2017.
//
//

import Foundation
import UIKit

public let accessoryViewHeight: CGFloat = 50.0

// MARK: - Accessory Views

public extension UITextField {
    
    public func addDoneInputAccessoryView() {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: accessoryViewHeight)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing(_:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleItem, doneButton], animated: true)
        toolbar.backgroundColor = UIColor.white
        
        self.inputAccessoryView = toolbar
    }
    
}
