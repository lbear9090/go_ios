//
//  SelectedUserCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 08/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SelectedUserCollectionViewCell: BaseCollectionViewCell {
    
    private let avatarImageView: UIImageView = {
        let imageView: UIImageView = UIImageView.newAutoLayout()
        imageView.image = .roundAvatarPlaceholder
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.textColor = .lightText
        label.textAlignment = .center
        return label
    }()
    
    private let removeImageView = UIImageView(image: .cancelButton)
    
    override func setup() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.removeImageView)
    }
    
    override func applyConstraints() {
        
        self.nameLabel.setContentHuggingPriority(.required, for: .vertical)
        self.nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.bottom.equalTo(self.nameLabel.snp.top)
            make.width.equalTo(self.avatarImageView.snp.height)
            make.centerX.equalToSuperview()
        }
        
        self.removeImageView.snp.makeConstraints { make in
            make.size.equalTo(15)
            make.bottom.equalTo(self.avatarImageView.snp.bottom)
            make.right.equalTo(self.avatarImageView.snp.right)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.makeCircular()
    }
    
    public func populate(with user: UserModel) {
        self.nameLabel.text = user.displayName
        
        if let imageUrlString = user.avatarImage?.mediumUrl,
            let imageUrl = URL(string: imageUrlString) {
            self.avatarImageView.kf.setImage(with: imageUrl, placeholder: UIImage.roundAvatarPlaceholder)
        }
        
        self.contentView.layoutIfNeeded()
    }
}
