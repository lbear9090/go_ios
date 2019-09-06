//
//  AddEventHeaderView.swift
//  Go
//
//  Created by Lucky on 09/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol AddEventHeaderViewDelegate {
    func didTapImageView(_ imageView: UIImageView)
}

class AddEventHeaderView: SHOView {
    
    var delegate: AddEventHeaderViewDelegate?
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: .addEvent)
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        let headerTGR = UITapGestureRecognizer(target: self,
                                               action: #selector(headerTapped))
        view.addGestureRecognizer(headerTGR)
        
        return view
    }()
    
    lazy var videoPlayer: VideoPlayerView = {
        let player = VideoPlayerView()
        player.isHidden = true
        let headerTGR = UITapGestureRecognizer(target: self,
                                               action: #selector(headerTapped))
        player.addGestureRecognizer(headerTGR)
        
        return player
    }()
    
    override func setup() {
        self.isUserInteractionEnabled = true
        self.addSubview(self.imageView)
        self.addSubview(self.videoPlayer)
    }
    
    override func applyConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.videoPlayer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - User actions
    
    @objc private func headerTapped() {
        delegate?.didTapImageView(self.imageView)
    }

}
