//
//  VideoPlayerView.swift
//  Go
//
//  Created by Lucky on 03/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol VideoPlayerViewDelegate: AnyObject {
    func didTapFullScreenButton(_ videoView: VideoPlayerView, videoURL: URL?)
    func didTapMediaSelectionButton(_ videoView: VideoPlayerView)
}

extension VideoPlayerViewDelegate {
    func didTapMediaSelectionButton(_ videoView: VideoPlayerView) { }
}

extension VideoPlayerViewDelegate where Self: SHOViewController {
    func didTapFullScreenButton(_ videoView: VideoPlayerView, videoURL: URL?) {
        guard let videoUrl = videoURL else {
            self.showErrorAlertWith(message: "EVENT_DETAILS_VIDEO_LOAD_ERROR".localized)
            return
        }
        
        var seekTime: CMTime? = nil
        
        if let item = videoView.player?.currentItem {
            seekTime = item.currentTime()
        }
        
        let videoPlayerController = AVPlayerViewController.configured(with: videoUrl, startPosition: seekTime)
        
        videoPlayerController.actionHandler = { [unowned videoView] (controller) in
            if let seekTime = controller.player?.currentTime() {
                videoView.player?.seek(to: seekTime)
                videoView.playButtonPressed()
            }
        }
        
        self.present(videoPlayerController, animated: true) {
            videoPlayerController.player?.play()
        }
    }
}

class VideoPlayerView: SHOView {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    weak var videoDelegate: VideoPlayerViewDelegate?
    
    lazy var fullScreenButton: UIButton = {
        let button: UIButton = UIButton.newAutoLayout()
        button.setBackgroundImage(.fullScreenIcon, for: .normal)
        button.addTarget(self, action: #selector(fullScreenButtonPressed), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var selectionButton: UIButton = {
        let button: UIButton = UIButton.newAutoLayout()
        button.setBackgroundImage(.selectMediaIcon, for: .normal)
        button.addTarget(self, action: #selector(mediaSelectionButtonPressed), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var enableSelectionMode: Bool = false {
        didSet {
            if self.enableSelectionMode {
                self.addSubview(self.selectionButton)
                self.bringSubview(toFront: self.selectionButton)
                self.selectionButton.snp.makeConstraints({ (make) in
                    make.left.equalTo(self.snp.leftMargin)
                    make.top.equalTo(self.snp.topMargin)
                    make.size.equalTo(CGSize(width: 30.0, height: 30.0))
                })
            }
        }
    }
    
    var videoURL: URL? {
        didSet {
            if let url = videoURL {
                self.configureAVPlayer(withUrl: url)
            }
        }
    }
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(.playIcon, for: .normal)
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    init() {
        super.init(frame: .zero)
    }
    
    init(url: URL) {
        self.videoURL = url
        super.init(frame: .zero)
        self.configureAVPlayer(withUrl: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.removeObserver(self, forKeyPath: "bounds")
    }
    
    // MARK: - View Setup
    
    override func setup() {
        self.addSubview(self.playButton)
        self.addSubview(self.fullScreenButton)
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userTappedView))
        tapGR.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGR)
        
        self.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    }
    
    override func applyConstraints() {
        self.playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        self.fullScreenButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.rightMargin)
            make.bottom.equalTo(self.snp.bottomMargin)
            make.size.equalTo(CGSize(width: 30.0, height: 30.0))
        }
    }
    
    func configureAVPlayer(withUrl videoUrl: URL) {
        if self.playerLayer != nil {
            self.playerLayer?.removeFromSuperlayer()
        }
        
        let asset = AVURLAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        
        // create a video layer for the player
        let embeddedLayer = AVPlayerLayer(player: self.player)
        
        // make the video fill the layer as much as possible while keeping its aspect size
        embeddedLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.playerLayer = embeddedLayer
        
        self.playButton.isHidden = false
        self.fullScreenButton.isHidden = true
        self.selectionButton.isHidden = true
        
        self.bringSubview(toFront: self.playButton)
        self.bringSubview(toFront: self.fullScreenButton)
        self.bringSubview(toFront: self.selectionButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackShouldStop),
                                               name: .stopPlayingVideo,
                                               object: nil)
    }
    
    
    // MARK: - User Actions
    
    @objc public func playButtonPressed() {
        if let embeddedLayer = self.playerLayer,
            let vidPlayer = self.player {
            if embeddedLayer.superlayer == nil {
                embeddedLayer.frame = self.bounds
                self.layer.addSublayer(embeddedLayer)
            }
            
            if vidPlayer.isPlaying {
                vidPlayer.pause()
            }
            else {
                vidPlayer.play()
            }
            
            self.playButton.isHidden = vidPlayer.isPlaying
            self.fullScreenButton.isHidden = !vidPlayer.isPlaying
            self.selectionButton.isHidden = !vidPlayer.isPlaying
            
            self.bringSubview(toFront: self.playButton)
            self.bringSubview(toFront: self.fullScreenButton)
            self.bringSubview(toFront: self.selectionButton)
        }
    }
    
    @objc public func playbackFinished() {
        self.player?.seek(to: kCMTimeZero)
        self.player?.pause()
        self.playerLayer?.removeFromSuperlayer()

        self.playButton.isHidden = false
        self.fullScreenButton.isHidden = true
        self.selectionButton.isHidden = true
        
        self.bringSubview(toFront: self.playButton)
        self.bringSubview(toFront: self.fullScreenButton)
        self.bringSubview(toFront: self.selectionButton)
    }
    
    @objc private func playbackShouldStop() {
        self.playbackFinished()
    }
    
    @objc private func fullScreenButtonPressed() {
        self.videoDelegate?.didTapFullScreenButton(self, videoURL: self.videoURL)
    }
    
    @objc private func mediaSelectionButtonPressed() {
        self.videoDelegate?.didTapMediaSelectionButton(self)
    }
    
    @objc private func userTappedView() {
        self.playButtonPressed()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "bounds") {
            self.playerLayer?.frame = self.bounds
            return
        }
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
