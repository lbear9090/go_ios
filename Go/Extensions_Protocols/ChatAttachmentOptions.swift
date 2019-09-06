//
//  ChatAttachmentOptions.swift
//  Go
//
//  Created by Nouman Tariq on 14/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

public enum ChatAttachmentOption {
    case photo
    case camera
    case location
}

public enum ChatMessageFailureOption {
    case resend
    case delete
}

extension UIAlertController {
    
    public typealias ChatAttachmentSelection = ((ChatAttachmentOption) -> Void)
    
    public static func showChatAttachmentOptions(on viewController: UIViewController, selectionHandler: ChatAttachmentSelection?) {
        let alertController = UIAlertController(title: "CHAT_ATTACHMENT_OPTIONS_TITLE".localized,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "CHAT_ATTACHMENT_CAMERA_OPTION".localized,
                                                style: .default) { action in
                                                    selectionHandler?(.camera)
        })
        
        alertController.addAction(UIAlertAction(title: "CHAT_ATTACHMENT_PHOTO_OPTION".localized,
                                                style: .default) { action in
                                                    selectionHandler?(.photo)
        })
        
        alertController.addAction(UIAlertAction(title: "CHAT_ATTACHMENT_LOCATION_OPTION".localized,
                                                style: .default) { action in
                                                    selectionHandler?(.location)
        })
        
        alertController.addAction(SHOViewController.cancelAction())
        
        viewController.present(alertController,
                               animated: true,
                               completion: nil)
    }
    
    public static func showFailedMessageOptions(on viewController: UIViewController, selectionHandler: ((ChatMessageFailureOption) -> Void)?) {
        let alertController = UIAlertController(title: "MESSAGE_FAILURE_OPTIONS_TITLE".localized,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "MESSAGE_FAILURE_RESEND_OPTION".localized,
                                                style: .default) { action in
                                                    selectionHandler?(.resend)
        })
        
        alertController.addAction(UIAlertAction(title: "MESSAGE_FAILURE_DELETE_OPTION".localized,
                                                style: .default) { action in
                                                    selectionHandler?(.delete)
        })
        
        alertController.addAction(SHOViewController.cancelAction())
        
        viewController.present(alertController,
                               animated: true,
                               completion: nil)
    }
}
