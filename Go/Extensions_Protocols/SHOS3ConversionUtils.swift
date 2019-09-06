//
//  SHOS3ConversionUtils.swift
//  Go
//
//  Created by Nouman Tariq on 08/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import AVKit

extension SHOS3Utils {
    
    public static func encodeVideo(_ videoURL: URL, completionHandler: ((URL?, Error?) -> Void)?)  {
        
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        
        //Create Export session
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        //Creating temp path to save the converted video
        let tempDir =  URL(fileURLWithPath: NSTemporaryDirectory())
        let filePath = tempDir.appendingPathComponent("rendered-Video.mp4")
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(atPath: filePath.path)
            }
            catch let error {
                completionHandler?(nil, error)
            }
        }
        
        exportSession?.outputURL = filePath
        exportSession?.outputFileType = .mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRangeMake(start, avAsset.duration)
        exportSession?.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession?.status {
            case .completed?:
                completionHandler?(exportSession?.outputURL, nil)
            default:
                let userInfo = [NSLocalizedDescriptionKey: "VIDEO_CONVERSION_FAILED".localized]
                let conversionError = NSError(domain: Constants.errorDomain, code: -1, userInfo: userInfo)
                completionHandler?(nil, conversionError)
            }
            
        })
    }
    
}
