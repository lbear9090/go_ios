//
//  EmptyStateTableViewCell.swift
//  Go
//
//  Created by Lucky on 17/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class EmptyStateTableViewCell: SHOTableViewCell {
    
    let emptyStateImageView: UIImageView = {
        let imageView: UIImageView = UIImageView.newAutoLayout()
        
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = .emptyState
        
        return imageView
    }()
    
    let emptyStateLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        
        label.font = Font.regular.withSize(.medium)
        label.textColor = .green
        label.textAlignment = .center
        label.text = "EMPTY_STATE_MESSAGE".localized
        label.numberOfLines = 0
        
        return label
    }()

    override func setup() {
        self.selectionStyle = .none
        self.contentView.addSubview(self.emptyStateImageView)
        self.contentView.addSubview(self.emptyStateLabel)
    }
    
    override func applyConstraints() {
        self.emptyStateImageView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.left.right.equalToSuperview()
        }
        
        self.emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emptyStateImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16.0)
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
        }
    }

}
