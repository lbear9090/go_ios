//
//  SHOS3Utils.swift
//  Go
//
//  Created by Lucky on 09/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import AWSS3
import CryptoSwift

public typealias S3UploadCompletion = (_ urlString: String?, _ error: Error?) -> Void

let errorDomain: String = "com.s3.error"

public struct UploadConfig {
    public let fileName: String
    public let directoryPath: String
    
    public init(fileName: String, directoryPath: String) {
        self.fileName = fileName
        self.directoryPath = directoryPath
    }
    
    public static func avatar(email: String) -> UploadConfig {
        return UploadConfig(fileName: "user_avatar_\(email)_\(Int(Date().timeIntervalSince1970))",
            directoryPath: "user_avatar_direct_upload/")
    }
}

public protocol S3Uploadable {
    var contentType: String { get }
    var fileExtension: String { get }
    
    func getData() throws -> Data
}

public struct SHOS3Utils {
    
    @discardableResult public static func upload(_ object: S3Uploadable,
                                                 configuration: UploadConfig,
                                                 completionHandler: @escaping S3UploadCompletion) -> AWSS3TransferManagerUploadRequest? {
        
        let digestedFileName = configuration.fileName.md5() + object.fileExtension
        
        let documentPathURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var fileURL: URL = documentPathURLs[0]
        fileURL.appendPathComponent(digestedFileName)
        
        do {
            let objectData = try object.getData()
            try objectData.write(to: fileURL, options: .atomic)
        } catch {
            completionHandler(nil, error)
            return nil
        }
        
        return SHOS3Utils.uploadFile(withUrl: fileURL,
                                     contentType: object.contentType,
                                     configuration: configuration,
                                     completionHandler: completionHandler)
    }
    
    @discardableResult public static func uploadFile(withUrl fileURL: URL,
                                                     contentType: String,
                                                     configuration: UploadConfig,
                                                     completionHandler: @escaping S3UploadCompletion) -> AWSS3TransferManagerUploadRequest? {
        
        guard let uploadRequest = AWSS3TransferManagerUploadRequest() else {
            let userInfo = [NSLocalizedDescriptionKey : NSLocalizedString("Unable to initialise upload request", comment: "")]
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: userInfo)
            completionHandler(nil, error)
            return nil
        }
        
        let resourceKey = configuration.directoryPath + fileURL.lastPathComponent
        
        uploadRequest.body = fileURL
        uploadRequest.key = resourceKey
        uploadRequest.bucket = SHOConfigurations.AWSBucketName.value
        uploadRequest.contentType = contentType
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread()) { (task: AWSTask<AnyObject>) in
            if task.result != nil {
                let urlString = SHOConfigurations.AWSBaseURL.value + resourceKey
                completionHandler(urlString, nil)
            } else if task.error != nil {
                completionHandler(nil, task.error)
            }
            return nil
        }
        return uploadRequest
    }
}

extension UIImage: S3Uploadable {
    public var contentType: String {
        return "image/jpeg"
    }
    
    public var fileExtension: String {
        return ".jpeg"
    }
    
    public func getData() throws -> Data {
        var actualHeight : CGFloat = self.size.height
        var actualWidth : CGFloat = self.size.width
        let maxHeight : CGFloat = 1136.0
        let maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else{
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            throw compressionError
        }
        UIGraphicsEndImageContext()
        
        guard let imageData = UIImageJPEGRepresentation(img, compressionQuality) else {
            throw compressionError
        }
        return imageData
    }
    
    public var compressionError: NSError {
        let userInfo = [NSLocalizedDescriptionKey : NSLocalizedString("An error occured during compression", comment: "")]
        return NSError(domain: errorDomain,
                       code: 0,
                       userInfo: userInfo)
    }
}
