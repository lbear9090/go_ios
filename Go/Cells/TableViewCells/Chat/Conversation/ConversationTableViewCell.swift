//
//  ConversationTableViewCell.swift
//  Go
//
//  Created by Lee Whelan on 23/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SwiftDate

private let ThumbnailDiameter: CGFloat = 45.0
private let CountViewDiameter: CGFloat = 16.0

class ConversationTableViewCell: SHOTableViewCell {
    
    let thumbnailImageView : UIImageView = {
       let view = UIImageView(frame: CGRect(origin: .zero,
                                            size: CGSize(width: ThumbnailDiameter, height: ThumbnailDiameter)))
        view.image = .conversationPlaceholder
        view.makeCircular(.scaleAspectFill)
        view.backgroundColor = .gray
       return view
    }()
    
    var countView: CircularCountView = CircularCountView()
    
    var titleLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = Font.regular.withSize(.large)
        return label
    }()
    
    var timestampLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = Font.regular.withSize(.small)
        label.textColor = .darkText
        label.textAlignment = .right
        return label
    }()
    
    var iconLabel: IconLabel = {
        var label: IconLabel = IconLabel(icon: .eventHostIcon)
        label.font = Font.regular.withSize(.small)
        return label
    }()
    
    var lastMessageLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = Font.regular.withSize(.small)
        return label
    }()
    
    var unreadCountView: CircularCountView = {
        var view: CircularCountView = CircularCountView.newAutoLayout()
        view.backgroundColor = .blue
        view.isHidden = true
        return view
    }()
    
    // MARK: Stack Views
    
    var detailStackView: UIStackView = {
        var view: UIStackView = UIStackView.newAutoLayout()
        view.axis = .vertical
        view.spacing = 3
        return view
    }()
    
    var detailTopStackView: UIStackView = {
        var view: UIStackView = UIStackView.newAutoLayout()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 5
        return view
    }()
    
    var detailBottomStackView: UIStackView = {
        var view: UIStackView = UIStackView.newAutoLayout()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 5
        return view
    }()
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = .none
        self.leftSeparatorMargin = 71.0
        
        self.contentView.addSubview(self.thumbnailImageView)
        self.contentView.addSubview(self.detailStackView)

        self.detailStackView.addArrangedSubview(self.detailTopStackView)
        self.detailStackView.addArrangedSubview(self.iconLabel)
        self.detailStackView.addArrangedSubview(self.detailBottomStackView)

        self.detailTopStackView.addArrangedSubview(self.countView)
        self.detailTopStackView.addArrangedSubview(self.titleLabel)
        self.detailTopStackView.addArrangedSubview(self.timestampLabel)

        self.detailBottomStackView.addArrangedSubview(self.lastMessageLabel)
        self.detailBottomStackView.addArrangedSubview(self.unreadCountView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.contentView.layoutMargins = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.contentView.snp.topMargin)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.size.equalTo(CGSize(width: ThumbnailDiameter, height: ThumbnailDiameter))
            make.bottom.greaterThanOrEqualTo(self.contentView.snp.bottomMargin)
        }
        
        self.detailStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.left.equalTo(self.thumbnailImageView.snp.right).offset(5)
        }
        
        self.countView.setContentHuggingPriority(.required, for: .horizontal)
        self.countView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.countView.snp.makeConstraints { (make) in
            make.height.equalTo(self.countView.snp.width)
        }
        
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.unreadCountView.setContentHuggingPriority(.required, for: .horizontal)
        self.unreadCountView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.unreadCountView.snp.makeConstraints { (make) in
            make.height.equalTo(self.unreadCountView.snp.width)
            make.size.equalTo(CGSize(width: CountViewDiameter, height: CountViewDiameter))
        }
        
        self.timestampLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func configure(conversation: Conversation) {
        if let event = conversation.event {
            if let imageURL = event.mediaItems?.first?.images?.mediumUrl {
                self.thumbnailImageView.kf.setImage(with: URL(string: imageURL),
                                                    placeholder: UIImage.conversationPlaceholder)
            }
            
            self.iconLabel.text = event.host.displayName
            self.iconLabel.isHidden = false
        }
        else {
            if let imageURL = conversation.image?.mediumUrl {
                self.thumbnailImageView.kf.setImage(with: URL(string: imageURL),
                                                        placeholder: UIImage.conversationPlaceholder)
            }
            
            self.iconLabel.isHidden = true
        }
        
        self.titleLabel.text = conversation.name
        self.countView.count = conversation.participantCounts
        
        let date = Date(timeIntervalSince1970: conversation.updatedAt)
        self.timestampLabel.text = date.colloquialSinceNow()
        
        if let message = conversation.messages.last {
            self.lastMessageLabel.text = message.text
        }
        else {
            self.lastMessageLabel.text = ""
        }
        
        self.unreadCountView.count = conversation.unreadCount
        self.unreadCountView.isHidden = !conversation.unread
    }
}
