//
//  BasePickerViewSheet.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

public typealias PickerViewSheetHandler = (_ sheet: BasePickerViewSheet) -> Void

open class BasePickerViewSheet: UIView {
    
    public static let PickerViewSheetHeight: CGFloat = 220.0
    
    open var dismissHandler: PickerViewSheetHandler?
    open var loadedHandler: PickerViewSheetHandler?
    
    public weak var responder: UIResponder?
    private var topConstraint: NSLayoutConstraint?
    private var didSetupConstraints: Bool = false
    
    open lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(hidePicker))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                             target: nil,
                                             action: nil)
        bar.setItems([flexibleButton, doneButton],
                     animated: true)
        
        return bar
    }()
    
    // MARK: - Internal Methods
    
    
    @objc func pickerLoaded() {
        self.loadedHandler?(self)
    }
}

// MARK: - View Setup

extension BasePickerViewSheet {
    open override func updateConstraints() {
        super.updateConstraints()
        
        if !self.didSetupConstraints {
            self.setup()
            self.applyConstraints()
            self.didSetupConstraints = true
        }
        
    }
    
    override open func setup() {
        self.addSubview(self.toolbar)
    }
    
    override open func applyConstraints() {
        self.toolbar.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50.0)
        }
    }
}

// MARK: - Toolbar Actions

extension BasePickerViewSheet {
    @objc public func hidePicker() {
        self.hidePickerWithCompletion { return }
    }
}

// MARK: - Public Methods

extension BasePickerViewSheet {
    
    open func showPicker(onController controller: UIViewController) {
        self.showPicker(controller.view)
    }
    
    open func showPicker(_ view: UIView) {
        DispatchQueue.main.async {
            view.endEditing(true)
            view.addSubview(self)
            
            self.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(BasePickerViewSheet.PickerViewSheetHeight)
                if let superview = self.superview {
                    self.topConstraint = make.top.equalTo(superview.snp.bottom).constraint.layoutConstraints.first
                }
            })
            
            view.layoutIfNeeded()
            
            UIView.animate(withDuration: Double(UINavigationControllerHideShowBarDuration), animations: {
                if let validConstraint = self.topConstraint {
                    validConstraint.constant = -(BasePickerViewSheet.PickerViewSheetHeight)
                    view.layoutIfNeeded()
                }
            }, completion: { [weak self] (finished) in
                self?.pickerLoaded()
            })
        }
    }
    
    open func hidePickerWithCompletion(_ handler: @escaping () -> Void?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(UINavigationControllerHideShowBarDuration), animations: {
                if let validConstraint = self.topConstraint,
                    let superview = self.superview {
                    validConstraint.constant = 0.0
                    superview.layoutIfNeeded()
                }
            }, completion: { (finished) in
                self.removeFromSuperview()
                
                if let responder = self.responder, responder.canResignFirstResponder {
                    responder.resignFirstResponder()
                }
                
                self.dismissHandler?(self)
                handler()
            })
        }
    }
}
