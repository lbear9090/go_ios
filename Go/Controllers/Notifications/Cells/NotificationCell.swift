//
//  BaseNotificationCell.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let AvatarImageViewSize = CGSize(width: 56, height: 56)
private let TypeImageViewSize = CGSize(width: 24, height: 24)

class NotificationCell: SHOTableViewCell {
    
    let titleLabel: UILabel = {
        let configs = LabelConfig(textFont: Font.bold.withSize(.small),
                                  textColor: .text)
        let label = UILabel(with: configs)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let configs = LabelConfig(textFont: Font.regular.withSize(.small),
                                  textColor: .text)
        let label = UILabel(with: configs)
        label.numberOfLines = 0
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let configs = LabelConfig(textFont: Font.regular.withSize(.small),
                                  textColor: .green)
        let label = UILabel(with: configs)
        return label
    }()
    
    let labelStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .vertical
        return stackView
    }()
    
    let avatarImageView: UIImageView = {
        let frame = CGRect(origin: .zero, size: AvatarImageViewSize)
        let imageView = UIImageView(frame: frame)
        imageView.image = .notificationPlaceholder
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let typeImageView: UIImageView = {
        let frame = CGRect(origin: .zero, size: TypeImageViewSize)
        let imageView = UIImageView(frame: frame)
        imageView.image = .notificationGeneric
        return imageView
    }()
    
    override func setup() {
        super.setup()
    
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.typeImageView)
        self.contentView.addSubview(self.labelStackView)
        self.labelStackView.addArrangedSubview(self.titleLabel)
        self.labelStackView.addArrangedSubview(self.subtitleLabel)
        self.labelStackView.addArrangedSubview(self.timestampLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.avatarImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15.0)
            make.size.equalTo(AvatarImageViewSize)
            make.top.greaterThanOrEqualTo(self.contentView.snp.topMargin)
            make.bottom.lessThanOrEqualTo(self.contentView.snp.bottomMargin)
        }
        
        self.typeImageView.snp.makeConstraints { (make) in
            make.size.equalTo(TypeImageViewSize)
            make.right.equalTo(self.avatarImageView.snp.right)
            make.bottom.equalTo(self.avatarImageView.snp.bottom)
        }
        
        self.labelStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(self.contentView.snp.topMargin)
            make.bottom.lessThanOrEqualTo(self.contentView.snp.bottomMargin)
            make.left.equalTo(self.avatarImageView.snp.right).offset(15.0)
            make.right.lessThanOrEqualTo(self.contentView.snp.rightMargin)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.makeCircular(.scaleAspectFill)
    }
    
    public func configure(with notification: NotificationModel) {

        let createAtDate = Date(timeIntervalSince1970: notification.createdAt)
        self.timestampLabel.text = createAtDate.string(withFormat: .shorthand)
        self.typeImageView.image = notification.type?.icon ?? .notificationGeneric
        self.backgroundColor = notification.status == .read ? .white : .notificationUnreadBackground
        
        let resources = notification.resources
        
        if let bundle = resources?.genericBundle,
            notification.type == .general {
            
            self.titleLabel.text = bundle.title
            self.subtitleLabel.text = bundle.message
            
            if let platformImageUrl = bundle.platform.images?.smallUrl {
                self.avatarImageView.kf.setImage(with: URL(string: platformImageUrl),
                                                 placeholder: UIImage.notificationPlaceholder)
            }
        } else if let user = resources?.user ?? resources?.friendRequest?.requestingUser {
            
            self.titleLabel.text = user.displayName
            self.subtitleLabel.text = notification.message
            
            if let avatarUrl = user.avatarImage?.smallUrl {
                self.avatarImageView.kf.setImage(with: URL(string: avatarUrl),
                                                 placeholder: UIImage.notificationPlaceholder)
            }
        } else if let event = resources?.event {
            self.titleLabel.text = event.title
            self.subtitleLabel.text = notification.message
            
            if let eventImageUrl = event.mediaItems.first?.images?.smallUrl {
                self.avatarImageView.kf.setImage(with: URL(string: eventImageUrl),
                                                 placeholder: UIImage.notificationPlaceholder)
            }
        }
        else {
            self.titleLabel.text = nil
            self.avatarImageView.image = .notificationPlaceholder
            self.subtitleLabel.text = notification.message
        }
    }
    
}
