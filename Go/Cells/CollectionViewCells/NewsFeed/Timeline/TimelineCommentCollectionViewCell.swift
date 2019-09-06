//
//  TimelineCommentCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 05/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SwiftDate

private let AvatarImageSize: CGSize = CGSize(width: 36, height: 36)

class TimelineCommentCollectionViewCell: BaseCollectionViewCell {
    
    public var showShadow: Bool = false {
        didSet {
            if showShadow {
                self.addBottomShadow()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }
    
    private let avatarImageView: UIImageView = {
        let frame = CGRect(origin: .zero, size: AvatarImageSize)
        let imageView = UIImageView(frame: frame)
        
        imageView.image = .roundAvatarPlaceholder
        imageView.makeCircular(.scaleAspectFill)
        imageView.backgroundColor = .gray
        
        return imageView
    }()
        
    private let commentLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.medium)
        label.textColor = .darkText
        label.numberOfLines = 1
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.extraSmall)
        label.textColor = .lightText
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4.0
        return stackView
    }()
    
    override func setup() {
        super.setup()
        self.separatorView.isHidden = false
        
        self.contentView.addSubview(self.stackView)
        self.contentView.addSubview(self.avatarImageView)
        self.stackView.addArrangedSubview(self.commentLabel)
        self.stackView.addArrangedSubview(self.timestampLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(AvatarImageSize)
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.top.equalTo(self.contentView.snp.topMargin)
            make.bottom.lessThanOrEqualTo(self.contentView.snp.bottomMargin)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImageView.snp.right).offset(8)
            make.top.equalTo(self.contentView.snp.topMargin)
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
        }
    }
    
    public func populate(with comment: CommentModel) {
        
        let username = comment.user.displayName
        let content = comment.content
        
        let commentText = (username + " ").attributedString(with: [.font: Font.semibold.withSize(.medium)])
        commentText.append(content.attributedString(with: [.font: Font.regular.withSize(.medium)]))
        self.commentLabel.attributedText = commentText
        
        let date = Date(timeIntervalSince1970: comment.updatedAt)
        self.timestampLabel.text = date.colloquialSinceNow()
        
        if let imageStr = comment.user.avatarImage?.mediumUrl {
            self.avatarImageView.kf.setImage(with: URL(string: imageStr),
                                                placeholder: UIImage.roundAvatarPlaceholder)
        }
    }
    
}
