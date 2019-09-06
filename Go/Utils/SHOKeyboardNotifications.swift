//
//  KeyboardNotifications.swift
//  SHOSwiftUtils
//
//  Created by Lee Whelan on 21/09/2017.
//
//

import Foundation
import UIKit

public protocol SHOKeyboardNotifications: class {
    var keyboardNotificationObservers: [NSObjectProtocol] { get set }
    func registerForKeyboardNotifications()
    func unregisterForKeyboardNotifications()
    func animateLayoutForKeyboard(frame: CGRect)
}

public extension SHOKeyboardNotifications where Self: UIViewController {
    
    public func registerForKeyboardNotifications() {
        let showNotification = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                                                      object: nil,
                                                                      queue: nil) { [unowned self] (notification) in
                                                                        self.keyboardWillShow(notification: notification)
        }
        
        let hideNotification = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                      object: nil,
                                                                      queue: nil) { [unowned self] (notification) in
                                                                        self.keyboardWillHide(notification: notification)
        }
        
        self.keyboardNotificationObservers = [showNotification, hideNotification]
    }
    
    public func unregisterForKeyboardNotifications() {
        self.keyboardNotificationObservers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo
        let keyboardValue = info?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardFrame = keyboardValue?.cgRectValue
        
        let animateDuration = info?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        UIView.animate(withDuration: animateDuration ?? 1.0) {
            self.animateLayoutForKeyboard(frame: keyboardFrame ?? .zero)
        }
    }
    
    private func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo
        let keyboardFrame = CGRect.zero
        
        let animateDuration = info?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        
        UIView.animate(withDuration: animateDuration ?? 1.0) {
            self.animateLayoutForKeyboard(frame: keyboardFrame)
        }
    }
    
}

