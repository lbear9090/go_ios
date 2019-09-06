//
//  VideoUploadable.swift
//  Go
//
//  Created by Killian Kenny on 13/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import SHONetworkManager
import Photos

typealias ConfiguredHandler = (VideoUploadable?, NSError?) -> Void

class VideoUploadable: S3Uploadable {
    
    private var videoUrl: URL
    
    public var contentType: String {
        return "video/mp4"
    }
    
    public var fileExtension: String {
        return ".mp4"
    }
    
    init(withUrl videoUrl: URL) {
        self.videoUrl = videoUrl
    }
    
    public func getData() throws -> Data {
        return try Data(contentsOf: self.videoUrl)
    }
    
    public static func createWithAsset(_ asset: PHAsset, configuredHandler: @escaping ConfiguredHandler) {
        
        PHImageManager.default().requestExportSession(forVideo: asset, options: nil, exportPreset: AVAssetExportPresetHighestQuality) { (exportSession, infoDict) in
            if let exportSession = exportSession,
                let urlAsset = exportSession.asset as? AVURLAsset {
                configuredHandler(VideoUploadable(withUrl: urlAsset.url), nil)
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "ERROR_CREATE_VIDEO_UPLOADABLE".localized]
                let error = NSError(domain: Constants.errorDomain, code: NSURLErrorBadURL, userInfo: userInfo)
                configuredHandler(nil, error)
            }
        }
    }
}
