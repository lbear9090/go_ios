//
//  InviteContactTableViewCell.swift
//  Go
//
//  Created by Lucky on 08/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class InviteContactTableViewCell: SHOTableViewCell {
    
    let avatarImageView = UIImageView(image: .largeRoundAvatarPlaceholder)
    
    let nameLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.large)
        label.textColor = .text
        return label
    }()
    
    let inviteLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.large)
        label.textColor = .lightText
        label.text = "FIND_FRIENDS_INVITE".localized
        return label
    }()
    
    override func setup() {
        super.setup()
        
        self.separatorView.isHidden = false
        self.leftSeparatorMargin = 60.0

        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.inviteLabel)
    }
    
    override func applyConstraints() {
        
        self.avatarImageView.setContentHuggingPriority(.required, for: .horizontal)
        self.avatarImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.equalTo(self.contentView.snp.leftMargin)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.avatarImageView.snp.right).offset(15)
            make.right.equalTo(self.inviteLabel.snp.left)
        }
        
        self.inviteLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.inviteLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.inviteLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.contentView.snp.rightMargin)
        }
        
        self.separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(self.nameLabel.snp.left)
            make.right.equalToSuperview().inset(self.rightSeparatorMargin)
            make.height.equalTo(Stylesheet.tableViewCellSeparatorHeight)
        }
        
    }

}
