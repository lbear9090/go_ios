//
//  EventDetailsCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let Spacing: CGFloat = 8.0
private let IconSize = CGSize(width: 12, height: 12)

protocol EventDetailsCollectionViewCellDelegate {
    func didTapGoButton()
}

class EventDetailsCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Variables
    
    var delegate: EventDetailsCollectionViewCellDelegate?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public let videoPlayer: VideoPlayerView = {
        let player = VideoPlayerView()
        player.isHidden = true
        return player
    }()
    
    private let privateImageView: UIImageView = UIImageView(image: .privateEventIcon)
    
    private let textContainerView: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .white90
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.semibold.withSize(.medium)
        label.textColor = .darkText
        return label
    }()

    private let locationLabel: UILabel = {
        let label = IconLabel(icon: .eventLocation)
        label.font = Font.regular.withSize(.small)
        label.textColor = .darkText
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = IconLabel(icon: .eventTime)
        label.font = Font.regular.withSize(.small)
        label.textColor = .darkText
        return label
    }()
    
    private lazy var goButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(.noAttendanceStateIcon, for: UIControlState())
        button.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        
        self.separatorView.isHidden = false
        
        self.contentView.addSubview(self.backgroundImageView)
        self.contentView.addSubview(self.videoPlayer)
        self.contentView.addSubview(self.privateImageView)
        self.contentView.addSubview(self.textContainerView)
        
        self.textContainerView.addSubview(self.nameLabel)
        self.textContainerView.addSubview(self.locationLabel)
        self.textContainerView.addSubview(self.timestampLabel)
        self.textContainerView.addSubview(self.goButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.backgroundImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.textContainerView.snp.top)
        }
        
        self.videoPlayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self.backgroundImageView.snp.edges)
        }
        
        self.textContainerView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }

        self.nameLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(Spacing)
            make.right.equalTo(self.goButton.snp.left).offset(Spacing)
        }
        
        self.locationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Spacing)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(Spacing/2)
            make.right.equalTo(self.goButton.snp.left).offset(Spacing)
        }
        
        self.timestampLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Spacing)
            make.top.equalTo(self.locationLabel.snp.bottom).offset(Spacing/2)
            make.bottom.equalToSuperview().inset(Spacing)
            make.right.equalTo(self.goButton.snp.left).offset(Spacing)
        }
        
        self.nameLabel.setContentHuggingPriority(.required, for: .vertical)
        self.locationLabel.setContentHuggingPriority(.required, for: .vertical)
        self.timestampLabel.setContentHuggingPriority(.required, for: .vertical)
        
        self.goButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview().inset(Spacing)
            make.width.equalTo(self.goButton.snp.height)
        }
        
        self.privateImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    //MARK: - Configure cell
    
    public func populate(withEvent event: EventModel) {
        self.nameLabel.text = event.title
        self.locationLabel.text = event.address
        
        if let dateString =  Date(timeIntervalSince1970: event.date).string(withFormat: .shorthand),
            let timeString = Date(timeIntervalSince1970: event.time).string(withFormat: .time) {
            self.timestampLabel.text = "\(timeString) • \(dateString.uppercased())"
        }
        
        if let imageUrl = event.mediaItems.first?.images?.largeUrl {
            self.backgroundImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage.eventPlaceholder)
        }
        
        if let videoURLStr = event.mediaItems.first?.videoUrl,
            let videoURL = URL(string: videoURLStr) {
            self.videoPlayer.videoURL = videoURL
            self.videoPlayer.isHidden = false
        }
        else {
            self.videoPlayer.isHidden = true
        }
        
        if let status = event.userAttendance?.status {
            self.goButton.setBackgroundImage(status.buttonImage, for: UIControlState())
        } else {
            self.goButton.setBackgroundImage(.noAttendanceStateIcon, for: UIControlState())
        }
        
        self.privateImageView.isHidden = !event.isPrivate
    }
    
    //MARK: - User interaction
    
    @objc private func goButtonTapped() {
        delegate?.didTapGoButton()
    }
    
    public func stopVideo() {
        self.videoPlayer.playbackFinished()
    }
}
