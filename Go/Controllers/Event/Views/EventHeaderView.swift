//
//  EventHeaderView.swift
//  Go
//
//  Created by Lucky on 18/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol EventHeaderViewDelegate: class {
    func didTapForwardButton(_ button: UIButton)
    func didTapTimelineButton(_ button: UIButton)
    func didTapChatButton(_ button: UIButton)
    func getContribution()
    func setAttendanceStatus(to status: AttendanceStatus)
    func showProfileForUser(_ user: UserModel)
    func showShareOptionsFor(event: EventModel)
}

class EventHeaderView: AvatarHeaderView {
    
    //MARK: - Properties
    
    weak var delegate: EventHeaderViewDelegate?
    
    private var event: EventModel?
    
    private let privateImageView: UIImageView = UIImageView(image: .privateEventIcon)
    
    let videoPlayer: VideoPlayerView = {
        let vPlayer = VideoPlayerView()
        vPlayer.isHidden = true
        return vPlayer
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let config = LabelConfig(textFont: Font.semibold.withSize(.medium),
                                 textColor: .text)
        let label = UILabel(with: config)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(showUserProfile))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGestureRecognizer)
        
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.bold.withSize(.large)
        label.textColor = .darkText
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()
    
    private let timeLabel: IconLabel = {
        let label = IconLabel(icon: .eventTime)
        label.font = Font.regular.withSize(.small)
        return label
    }()
    
    lazy var attendButton: CircleMenu = {
        let button = CircleMenu(frame: .zero,
                                normalIcon: nil,
                                selectedIcon: .cancelButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        button.setBackgroundImage(.noAttendanceStateIcon, for: UIControlState())
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.setImage(.forwardButton, for: .normal)
        button.setImage(.forwardButtonInactive, for: .disabled)
        button.addTarget(self,
                         action: #selector(forwardButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var timelineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.setImage(.timlineButton, for: .normal)
        button.setImage(.timelineButtonInactive, for: .disabled)
        button.addTarget(self,
                         action: #selector(timelineButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.setImage(.messagesButton, for: .normal)
        button.setImage(.messagesButtonInactive, for: .disabled)
        button.addTarget(self,
                         action: #selector(chatButtonTapped),
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
    
    private let actionsStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - View Setup
    
    override func setup() {
        super.setup()
        
        let avatarTGR = UITapGestureRecognizer(target: self,
                                               action: #selector(showUserProfile))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(avatarTGR)
        
        self.addSubview(self.videoPlayer)
        self.addSubview(self.displayNameLabel)
        self.addSubview(self.titleLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.actionsStackView)
        self.addSubview(self.attendButton)
        self.addSubview(self.privateImageView)
        
        self.actionsStackView.addArrangedSubview(self.shareButton)
        self.actionsStackView.addArrangedSubview(self.forwardButton)
        self.actionsStackView.addArrangedSubview(self.timelineButton)
        self.actionsStackView.addArrangedSubview(self.chatButton)
        
        self.bringSubview(toFront: self.avatarImageView)
        self.bringSubview(toFront: self.privateImageView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.headerImageView.snp.updateConstraints { (make) in
            make.height.equalTo(Constants.mediaHeight)
        }
        
        self.displayNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.avatarImageView.snp.left)
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(8.0)
            make.right.equalTo(self.snp.rightMargin)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(displayNameLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(self.attendButton.snp.left).offset(-8)

        }

        self.timeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(5.0)
            make.right.equalTo(self.attendButton.snp.left).offset(-8)
        }
        
        self.attendButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(self.titleLabel.snp.top)
            make.right.equalToSuperview().inset(16)
        }
        
        self.actionsStackView.snp.makeConstraints { make in
            make.top.equalTo(self.headerImageView.snp.bottom).offset(4)
            make.right.equalToSuperview().inset(16)
        }
        
        self.videoPlayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self.headerImageView.snp.edges)
        }
        
        self.privateImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    public func populate(with event: EventModel) {
        self.event = event
        
        titleLabel.text = event.title
        displayNameLabel.text = event.host.displayName

        if let avatarUrlString = event.host.avatarImage?.smallUrl {
            avatarImageView.kf.setImage(with: URL(string: avatarUrlString),
                                        placeholder: UIImage.avatarPlaceholder)
        }
        
        if let eventImageUrl = event.mediaItems.first?.images?.mediumUrl {
            self.headerImageView.kf.setImage(with: URL(string: eventImageUrl),
                                             placeholder: UIImage.headerPlaceholder)
        }
        
        let eventDate = Date(timeIntervalSince1970: event.date).string(withFormat: .shorthand)
        let eventTime = Date(timeIntervalSince1970: event.time).string(withFormat: .time)
        
        if let dateString = eventDate,
            let timeString = eventTime {
            timeLabel.text = "\(timeString) • \(dateString.uppercased())"
        }
        
        self.forwardButton.isEnabled = event.allowsForwarding
        
        let timelineEnabled = event.showTimeline && event.userAttendance?.status == .going
        self.timelineButton.isEnabled = timelineEnabled
        
        let chatEnabled = event.allowChat && event.userAttendance?.status == .going
        self.chatButton.isEnabled = chatEnabled
        
        if let attendance = event.userAttendance {
            self.setAttendanceState(to: attendance.status)
        }
        
        if let videoUrlString = self.event?.mediaItems.first?.videoUrl,
            let url = URL(string: videoUrlString) {
            self.videoPlayer.videoURL = url
            self.videoPlayer.isHidden = false
        }
        
        self.privateImageView.isHidden = !event.isPrivate
    }
    
    public func setAttendanceState(to state: AttendanceStatus) {
        self.attendButton.setBackgroundImage(state.buttonImage, for: UIControlState())
    }
    
    //MARK: - User interaction
    
    @objc private func forwardButtonTapped(_ sender: UIButton) {
        delegate?.didTapForwardButton(sender)
    }
    
    @objc private func timelineButtonTapped(_ sender: UIButton) {
        delegate?.didTapTimelineButton(sender)
    }
    
    @objc private func chatButtonTapped(_ sender: UIButton) {
        delegate?.didTapChatButton(sender)
    }
    
    @objc private func showUserProfile() {
        if let user = self.event?.host {
            delegate?.showProfileForUser(user)
        }
    }
    
    @objc private func shareButtonTapped() {
        if let event = self.event {
            self.delegate?.showShareOptionsFor(event: event)
        }
    }
    
}

extension EventHeaderView: CircleMenuDelegate {

    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        guard let event = self.event else {
            return
        }
        let selectedStatus = AttendanceStatus.forButtonSelected(at: atIndex)
        
        if selectedStatus == .going {
            
            let request = event.userAttendance?.request
            
            //Request attendance before contribution flow if required
            if event.isPublicByInvite && !(request?.status == .accepted) {
                self.delegate?.setAttendanceStatus(to: selectedStatus)
                return
            }
            
            if (event.contribution?.amount.cents ?? 0) > 0 &&
                event.userAttendance?.contribution?.status != .paid {
                delegate?.getContribution()
                return
            }
        }
        
        self.delegate?.setAttendanceStatus(to: selectedStatus)
    }

}

