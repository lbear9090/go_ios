//
//  GoMessageInputBar.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

protocol GoMessageInputBarDelegate: AnyObject {
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressSendButton button: InputBarButtonItem, with text: String)
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressAttachmentButton button: InputBarButtonItem)
}

extension GoMessageInputBarDelegate {
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressAttachmentButton button: InputBarButtonItem) { }
}

class GoMessageInputBar: MessageInputBar {
    
    // MARK: - Convenience Methods -
    
    weak var customDelegate: GoMessageInputBarDelegate?
    
    // MARK: - Custom InputBarButtonItems -
    
    open lazy var attachmentInputBarButtonItem: InputBarButtonItem = {
        return InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
                $0.image = .chatInputBarAddMedia
            }.onTouchUpInside {
                self.sendAttachment($0)
        }
    }()
    
    open lazy var sendInputBarButtonItem: InputBarButtonItem = {
        return InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
                $0.image = .chatInputBarSend
            }.onTouchUpInside {
                self.sendText($0)
        }
    }()
    
    // MARK: - Delegate methods -
    
    @objc func sendAttachment(_ sender: InputBarButtonItem) {
        self.customDelegate?.messageInputBar(self, didPressAttachmentButton: sender)
    }
    
    @objc func sendText(_ sender: InputBarButtonItem) {
        self.customDelegate?.messageInputBar(self, didPressSendButton: sender, with: self.text)
    }
    
}
