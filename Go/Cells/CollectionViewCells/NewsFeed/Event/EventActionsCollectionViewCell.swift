//
//  EventActionsCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import OnlyPictures

private let Spacing: CGFloat = 8.0
private let CountViewSize = CGSize(width: 24, height: 24)
private let AvatarsViewSize = CGSize(width: 40, height: 24)

protocol EventActionsCollectionViewCellDelegate: class {
    func didTapForwardButton()
    func didTapTimelineButton()
    func didTapMessagingButton()
    func didTapShareButton()
}

class EventActionsCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    public var delegate: EventActionsCollectionViewCellDelegate?
    private var avatarImageUrls: [String] = []
    private let countView = CircularCountView()
    
    private lazy var avatarsView: OnlyPictures = {
        let pictures: OnlyHorizontalPictures = OnlyHorizontalPictures.newAutoLayout()
        pictures.frame = CGRect(origin: .zero, size: AvatarsViewSize)
        pictures.dataSource = self
        pictures.backgroundColor = .clear
        return pictures
    }()
    
    private let label: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.extraSmall)
        label.textColor = UIColor.lightText
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.forwardButton, for: .normal)
        button.setImage(.forwardButtonInactive, for: .disabled)
        button.addTarget(self,
                         action: #selector(forwardButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var timelineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.timlineButton, for: .normal)
        button.setImage(.timelineButtonInactive, for: .disabled)
        button.addTarget(self,
                         action: #selector(timelineButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var messagesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.messagesButton, for: .normal)
        button.setImage(.messagesButtonInactive, for: .disabled)
        button.addTarget(self,
                         action: #selector(messagingButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.shareButton, for: .normal)
        button.addTarget(self,
                         action: #selector(shareButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        
        self.separatorView.isHidden = false
        self.addBottomShadow()
        
        self.contentView.addSubview(self.countView)
        self.contentView.addSubview(self.avatarsView)
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.buttonStackView)
        
        self.buttonStackView.addArrangedSubview(self.shareButton)
        self.buttonStackView.addArrangedSubview(self.forwardButton)
        self.buttonStackView.addArrangedSubview(self.timelineButton)
        self.buttonStackView.addArrangedSubview(self.messagesButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.countView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CountViewSize)
            make.left.equalToSuperview().inset(Spacing)
        }
        
        self.avatarsView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(AvatarsViewSize)
            make.left.equalTo(self.countView.snp.right).offset(Spacing)
        }
        
        self.label.snp.makeConstraints { make in
            make.top.equalTo(self.avatarsView.snp.top)
            make.bottom.equalTo(self.avatarsView.snp.bottom)
            make.left.equalTo(self.avatarsView.snp.right).offset(Spacing/2)
        }
        
        self.buttonStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(Spacing)
            make.left.equalTo(self.label.snp.right).offset(Spacing/2)
            make.width.equalTo(111.0)
        }
    }
    
    //MARK: - Configuration
    
    public func populate(withEvent event: EventModel) {
        if event.friendsAttendingCount > 0 {
            self.label.text = String(format: "EVENT_DETAILS_FRIENDS_ATTENDING".localized, event.friendsAttendingCount)
        } else {
            self.label.text = nil
        }
        
        self.countView.count = event.attendeeCount
        
        self.forwardButton.isEnabled = event.allowsForwarding
        
        let timelineEnabled = event.showTimeline && event.userAttendance?.status == .going
        self.timelineButton.isEnabled = timelineEnabled
        
        let chatEnabled = event.allowChat && event.userAttendance?.status == .going
        self.messagesButton.isEnabled = chatEnabled
        
        self.avatarImageUrls = event.attendingFriends.compactMap { user -> String? in
            return user.avatarImage?.smallUrl
        }
        
        self.avatarsView.isHidden = avatarImageUrls.count == 0
        self.avatarsView.reloadData()
    }
    
    //MARK: - User interaction
    
    @objc private func forwardButtonTapped() {
        delegate?.didTapForwardButton()
    }
    
    @objc private func timelineButtonTapped() {
        delegate?.didTapTimelineButton()
    }
    
    @objc private func messagingButtonTapped() {
        delegate?.didTapMessagingButton()
    }
    
    @objc private func shareButtonTapped() {
        delegate?.didTapShareButton()
    }
}

//MARK: - OnlyPicturesDataSource

extension EventActionsCollectionViewCell: OnlyPicturesDataSource {
    
    func numberOfPictures() -> Int {
        return self.avatarImageUrls.count
    }
    
    func pictureViews(index: Int) -> UIImage {
        return .roundAvatarPlaceholder
    }
    
    func pictureViews(_ imageView: UIImageView, index: Int) {
        if let imageUrl = URL(string: avatarImageUrls[index]) {
            imageView.kf.setImage(with: imageUrl, placeholder: UIImage.roundAvatarPlaceholder)
        }
    }
}
