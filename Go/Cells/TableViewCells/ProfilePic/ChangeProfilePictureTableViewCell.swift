//
//  ChangeProfilePictureTableViewCell.swift
//  Go
//
//  Created by Lucky on 15/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class ChangeProfilePictureTableViewCell: SHOTableViewCell {
    
    var editActionHandler: ((UIImageView) -> Void)?
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: .avatarPlaceholder)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1.0
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let editIcon: UIImageView = UIImageView(image: .editIcon)
    
    // View Setup
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.avatarImageView)
        self.avatarImageView.addSubview(self.editIcon)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editButtonPressed))
        self.avatarImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.avatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 128.0, height: 128.0))
        }
        
        self.editIcon.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.avatarImageView.snp.bottomMargin)
            make.right.equalTo(self.avatarImageView.snp.rightMargin)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.avatarImageView.bringSubview(toFront: self.editIcon)
    }
    
    // User Action
    
    @objc func editButtonPressed() {
        self.editActionHandler?(self.avatarImageView)
    }
}
