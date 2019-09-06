//
//  InvitationNotificationCell.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Kingfisher

class InvitationNotificationCell: NotificationCell {
    
    lazy var accessoryImageView: UIImageView = {
        let imageView: UIImageView = UIImageView.newAutoLayout()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func setup() {
        super.setup()
        
        self.contentView.addSubview(self.accessoryImageView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.accessoryImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.size.equalTo(CGSize(width: 40.0, height: 40.0))
            make.left.equalTo(self.labelStackView.snp.right).offset(8.0)
        }
    }
    
    override func configure(with notification: NotificationModel) {
        super.configure(with: notification)
        if let event = notification.resources?.event {
            self.titleLabel.text = event.host.displayName
            
            if let avatarUrl = event.host.avatarImage?.smallUrl {
                self.avatarImageView.kf.setImage(with: URL(string: avatarUrl),
                                                 placeholder: UIImage.notificationPlaceholder)
            }
            
            if let imageUrl = event.mediaItems.first?.images?.largeUrl {
                self.accessoryImageView.kf.setImage(with: URL(string: imageUrl),
                                                placeholder: UIImage.squareEventPlaceholder)
            }
        }
    }
    
}
