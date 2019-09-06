//
//  SHOImageViewerUtils.swift
//  Go
//
//  Created by Lee Whelan on 10/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import SKPhotoBrowser
import Foundation
import UIKit

public protocol ViewableMedia {
    var skPhoto: SKPhoto { get }
}

extension UIImage: ViewableMedia {
    
    public var skPhoto: SKPhoto {
        return SKPhoto.photoWithImage(self)
    }
}

extension String: ViewableMedia {
    
    public var skPhoto: SKPhoto {
        let photo = SKPhoto.photoWithImageURL(self)
        photo.shouldCachePhotoURLImage = true
        return photo
    }
}

public class SHOImageViewerUtils: NSObject {
    
    public typealias CustomiseHandler = (SKPhotoBrowser) -> Void
    
    private weak var controller: UIViewController?
    public var browser: SKPhotoBrowser?
    private var startIndex: Int = 0
    private var skPhotos: [SKPhoto] = []
    
    // convenience handler to customise browser on the fly
    public var customizationHandler: CustomiseHandler?
    
    public var objects: [ViewableMedia] = [] {
        didSet {
            self.skPhotos = self.objects.map { media -> SKPhoto in
                return media.skPhoto
            }
        }
    }
    
    public convenience init(controller: UIViewController,
                            objects: [ViewableMedia],
                            startIndex: Int = 0) {
        self.init()
        self.startIndex = startIndex
        self.controller = controller
        
        defer {
            self.objects = objects
        }
    }
    
    public func show() {
        guard self.skPhotos.count > 0 else {
            return
        }
        
        self.browser = SKPhotoBrowser(photos: skPhotos)
        
        if let browser = self.browser {
            self.customizationHandler?(browser)
            browser.initializePageIndex(self.startIndex)
            self.controller?.present(browser, animated: true, completion: nil)
        }
    }
    
    public func dismiss() {
        self.browser?.dismissPhotoBrowser(animated: true)
    }
    
}
