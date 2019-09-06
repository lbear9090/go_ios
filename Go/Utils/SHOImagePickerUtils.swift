//
//  SHOImagePickerUtils.swift
//  Go
//
//  Created by Lee Whelan on 10/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import OpalImagePicker
import Photos

open class SHOImagePickerUtils: NSObject {
    
    public typealias imageSelectionClosure = (([UIImage]) -> Void)?
    public typealias imageVideoSelectionClosure = ((UIImage?, URL?, NSError?) -> Void)?
    public typealias cancelledClosure = (() -> Void)?
    
    open var libraryPickerTintColor: UIColor?
    open var libraryPickerBarTintColor: UIColor?
    open lazy var maxSelectionExceededString: String = String(format: "You may only select %d item%@ at a time!".localized,
                                                              self.maxSelection, self.maxSelection > 1 ? "s" : "")
    
    public var imageSelectedHandler: imageSelectionClosure
    public var imageVideoSelectionHandler: imageVideoSelectionClosure
    public var cancelledHandler: cancelledClosure
    
    private weak var controller: UIViewController?
    private var maxSelection: Int = 1
    
    public init(with controller: UIViewController, maxSelectable: Int = 1) {
        super.init()
        self.controller = controller
        self.maxSelection = maxSelectable
    }
    
    public var imageActionSheet: UIAlertController {
        let alertController = UIAlertController(title: "Choose Photo Option".localized,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Take New Photo".localized,
                                                style: .default) { action in
                                                    self.showCamera()
        })
        
        alertController.addAction(UIAlertAction(title: "Choose Existing Photo".localized,
                                                style: .default) { action in
                                                    self.showPhotoLibrary()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized,
                                                style: .cancel) { action in
                                                    alertController.dismiss(animated: true,
                                                                            completion: nil)
                                                    
        })
        
        return alertController
    }
    
    public var imageVideoActionSheet: UIAlertController {
        let alertController = UIAlertController(title: "Choose Media Option".localized,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Take New Photo/Video".localized,
                                                style: .default) { action in
                                                    self.showCamera(allowVideo: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Choose Existing Photo/Video".localized,
                                                style: .default) { action in
                                                    self.showPhotoLibrary(allowVideo: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized,
                                                style: .cancel) { action in
                                                    alertController.dismiss(animated: true,
                                                                            completion: nil)
                                                    
        })
        
        return alertController
    }
    
    open func openImageActionSheet(withSelectionHandler selectionHandler: imageSelectionClosure, cancelledHandler: cancelledClosure = nil) {
        self.imageSelectedHandler = selectionHandler
        self.cancelledHandler = cancelledHandler
        
        self.controller?.present(self.imageActionSheet, animated: true, completion: nil)
    }
    
    open func openImageVideoActionSheet(withSelectionHandler selectionHandler: imageVideoSelectionClosure, cancelledHandler: cancelledClosure = nil) {
        self.imageVideoSelectionHandler = selectionHandler
        self.cancelledHandler = cancelledHandler
        
        self.controller?.present(self.imageVideoActionSheet, animated: true, completion: nil)
    }
}

// MARK: - Actions

public extension SHOImagePickerUtils {
    
    @objc public func showCamera(allowVideo: Bool = false) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = true
            picker.delegate = self
            
            if allowVideo,
                let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                picker.mediaTypes = availableTypes
            }
            
            self.controller?.present(picker, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Camera Unavailable".localized,
                                          message: "Unable to find a camera on your device.".localized,
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK".localized, style: .default) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(okAction)
            
            self.controller?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc public func showPhotoLibrary(allowVideo: Bool = false) {
        let picker = OpalImagePickerController()
        picker.imagePickerDelegate = self
        picker.maximumSelectionsAllowed = self.maxSelection
        
        var mediaTypes: Set = [PHAssetMediaType.image]
        if allowVideo {
            mediaTypes.update(with: PHAssetMediaType.video)
        }
        picker.allowedMediaTypes = mediaTypes
        
        if let tintColor = self.libraryPickerTintColor {
            picker.navigationBar.tintColor = tintColor;
            picker.navigationBar.titleTextAttributes = [.foregroundColor : tintColor]
        }
        
        if let barTintColor = self.libraryPickerBarTintColor {
            picker.navigationBar.barTintColor = barTintColor
        }
        
        let configuration = OpalImagePickerConfiguration()
        configuration.maximumSelectionsAllowedMessage = self.maxSelectionExceededString
        picker.configuration = configuration
        
        self.controller?.present(picker, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension SHOImagePickerUtils: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageHandler = self.imageSelectedHandler {
                imageHandler([image])
            }
            if let imageVideoHandler = self.imageVideoSelectionHandler {
                imageVideoHandler(image, nil, nil)
            }
        }
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            let urlAsset = AVURLAsset(url: videoUrl)
            let imageGenerator = AVAssetImageGenerator(asset: urlAsset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time: CMTime = kCMTimeZero
            
            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
                self.imageVideoSelectionHandler?(image, videoUrl, nil)
                
            } catch let error as NSError {
                self.imageVideoSelectionHandler?(nil, videoUrl, error)
            }
        }
        
        self.controller?.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.controller?.dismiss(animated: true, completion: nil)
        self.cancelledHandler?()
    }
    
}

extension SHOImagePickerUtils: OpalImagePickerControllerDelegate {
    
    public func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        self.imageSelectedHandler?(images)
        self.controller?.dismiss(animated: true, completion: nil)
    }
    
    public func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        if let asset = assets.first {
            
            var image: UIImage?
            
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            manager.requestImage(for: asset,
                                 targetSize: PHImageManagerMaximumSize,
                                 contentMode: .aspectFill,
                                 options: options) { (assetImage, dictInfo) in
                                    image = assetImage
            }
            
            if asset.mediaType == .video {
                asset.writeToTemp { (url, error) in
                    if let error = error {
                        self.imageVideoSelectionHandler?(image, url, error as NSError)
                    } else {
                        self.imageVideoSelectionHandler?(image, url, nil)
                    }
                }
            } else {
                self.imageVideoSelectionHandler?(image, nil, nil)
            }
        }
    }
    
    public func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        self.cancelledHandler?()
    }
    
}

extension PHAsset {
    
    public func writeToTemp(with completionHandler: @escaping (URL?, Error?) -> Void) {
        guard let resource = PHAssetResource.assetResources(for: self).first else {
            let userInfo = [NSLocalizedDescriptionKey: "Could not create resource from Photos asset"]
            let error = NSError(domain: "ie.showoff.error", code: 0, userInfo: userInfo)
            completionHandler(nil, error)
            return
        }
        
        let fileName = resource.originalFilename
        let pathToWrite = NSTemporaryDirectory().appending(fileName)
        let fileUrl = URL(fileURLWithPath: pathToWrite)
        
        if FileManager.default.fileExists(atPath: pathToWrite) {
            completionHandler(fileUrl, nil)
            return
        }
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: fileUrl, options: options) { error in
            DispatchQueue.main.async {
                completionHandler(fileUrl, error)
            }
        }
    }
}

