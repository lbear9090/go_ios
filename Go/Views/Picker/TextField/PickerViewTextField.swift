//
//  PickerViewTextField.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

class PickerViewTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        switch action{
        case #selector(cut(_:)):
            return false
        case #selector(paste(_:)):
            return false
        case #selector(delete(_:)):
            return false
        default:
            return super.canPerformAction(action, withSender: sender)
        }
        
    }
    
}
