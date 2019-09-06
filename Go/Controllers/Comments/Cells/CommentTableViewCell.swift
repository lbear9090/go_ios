//
//  CommentTableViewCell.swift
//  Go
//
//  Created by Lucky on 07/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let ThumbnailDiameter: CGFloat = 36.0

class CommentTableViewCell: SHOTableViewCell {
    
    //MARK: - Properties
    
    let thumbnailImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: ThumbnailDiameter, height: ThumbnailDiameter)))
        view.image = .roundAvatarPlaceholder
        view.makeCircular(.scaleAspectFill)
        view.backgroundColor = .gray
        return view
    }()
    
    private let commentLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.textColor = .darkText
        label.numberOfLines = 0
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
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 4.0
        return stackView
    }()
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        self.separatorView.isHidden = false
        self.contentView.addSubview(self.stackView)
        self.contentView.addSubview(self.thumbnailImageView)
        
        self.stackView.addArrangedSubview(self.commentLabel)
        self.stackView.addArrangedSubview(self.timestampLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.bottom.lessThanOrEqualTo(self.contentView.snp.bottomMargin)
            make.size.equalTo(CGSize(width: ThumbnailDiameter, height: ThumbnailDiameter))
        }
        
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
            make.left.equalTo(self.thumbnailImageView.snp.right).offset(8.0)
        }
        
        
        [self.commentLabel, self.timestampLabel].forEach {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
    }
    
    //MARK: - Configuration
    
    public func populate(with comment: CommentModel) {
        
        let username = comment.user.displayName
        let content = comment.content
        
        let commentText = (username + " ").attributedString(with: [.font: Font.bold.withSize(.medium)])
        commentText.append(content.attributedString(with: [.font: Font.regular.withSize(.medium)]))
        self.commentLabel.attributedText = commentText
        
        let date = Date(timeIntervalSince1970: comment.updatedAt)
        self.timestampLabel.text = date.colloquialSinceNow()
        
        if let imageStr = comment.user.avatarImage?.mediumUrl {
            self.thumbnailImageView.kf.setImage(with: URL(string: imageStr),
                                                placeholder: UIImage.roundAvatarPlaceholder)
        }
    }

}
