//
//  AVPlayerViewController+Convenience.swift
//  Go
//
//  Created by Killian Kenny on 14/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import AVKit

public typealias AVPlayerActionHandler = (_ controller: AVPlayerViewController) -> Void

protocol AVPlayerExternalProperties {
    var actionHandler: AVPlayerActionHandler? { set get }
}

extension AVPlayerViewController {
    
    static func configured(with url: URL, startPosition: CMTime? = nil) -> AVPlayerViewController {
        
        let videoPlayerController = AVPlayerViewController()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.overrideOutputAudioPort(.none)
            try audioSession.setActive(true)
        } catch {
            print("AVPlayer setup error \(error.localizedDescription)")
        }
        
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        if let startPosition = startPosition {
            player.seek(to: startPosition)
        }
        
        videoPlayerController.player = player
        
        return videoPlayerController
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.actionHandler?(self)
    }
    
}

private var actionHandlerAssociationKey: UInt8 = 0

extension AVPlayerViewController: AVPlayerExternalProperties {
    var actionHandler: AVPlayerActionHandler? {
        get {
            return objc_getAssociatedObject(self, &actionHandlerAssociationKey) as? AVPlayerActionHandler
        }
        set(newValue) {
            objc_setAssociatedObject(self, &actionHandlerAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}
