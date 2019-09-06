//
//  TimelineCoverCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

class TimelineCoverCollectionViewCell: BaseCollectionViewCell {
    
    var videoUrlString: String? {
        didSet {
            if let urlStr = self.videoUrlString,
                let url = URL(string: urlStr) {
                self.videoPlayer.isHidden = false
                self.videoPlayer.videoURL = url
            } else {
                self.videoPlayer.isHidden = true
            }
        }
    }
    
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .timelinePlaceholder
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let videoPlayer: VideoPlayerView = {
        let vPlayer = VideoPlayerView()
        vPlayer.isHidden = true
        return vPlayer
    }()
    
    override func setup() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.videoPlayer)
    }
    
    override func applyConstraints() {
        self.coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.videoPlayer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func setImage(withUrlString urlString: String) {
        coverImageView.kf.setImage(with: URL(string: urlString),
                                   placeholder: UIImage.timelinePlaceholder)
    }
    
    public func stopVideo() {
        self.videoPlayer.playbackFinished()
    }
    
}
