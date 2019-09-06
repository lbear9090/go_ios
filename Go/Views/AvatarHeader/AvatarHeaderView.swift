//
//  AvatarHeaderView.swift
//  Go
//
//  Created by Lucky on 19/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let HeaderViewHeight = 204.0
private let AvatarViewHeight = 114.0

class AvatarHeaderView: BaseTableHeaderView {

    let headerImageView: UIImageView = {
        let imageView = UIImageView(image: .headerPlaceholder)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: .avatarPlaceholder)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    // MARK: - View Setup
    
    override func setup() {
        self.addSubview(self.headerImageView)
        self.addSubview(self.avatarImageView)
    }
    
    override func applyConstraints() {
        self.layoutMargins = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
        
        self.headerImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(HeaderViewHeight)
        }
        
        self.avatarImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: AvatarViewHeight, height: AvatarViewHeight))
            make.centerY.equalTo(self.headerImageView.snp.bottom)
            make.left.equalTo(self.snp.leftMargin)
            make.bottom.lessThanOrEqualTo(self.snp.bottomMargin)
        }
    }
    
}
