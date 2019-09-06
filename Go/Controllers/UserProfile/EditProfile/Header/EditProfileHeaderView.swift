//
//  EditProfileHeaderView.swift
//  Go
//
//  Created by Lucky on 02/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class EditProfileHeaderView: AvatarHeaderView {
    
    var avatarTapHandler: ((_ imageView: UIImageView) -> Void)?
    var coverTapHandler: ((_ imageView: UIImageView) -> Void)?
    
    private let editAvatarImageView = UIImageView(image: .editIcon)
    private let editCoverImageView = UIImageView(image: .editIcon)
    
    override func setup() {
        super.setup()
        self.avatarImageView.addSubview(self.editAvatarImageView)
        self.headerImageView.addSubview(self.editCoverImageView)
        
        let avatarTGR = UITapGestureRecognizer(target: self,
                                               action: #selector(avatarImageViewTapped))
        self.avatarImageView.addGestureRecognizer(avatarTGR)
        self.avatarImageView.isUserInteractionEnabled = true
        
        let coverTGR = UITapGestureRecognizer(target: self,
                                              action: #selector(coverImageViewTapped))
        self.headerImageView.addGestureRecognizer(coverTGR)
        self.headerImageView.isUserInteractionEnabled = true
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.editAvatarImageView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
        }
        
        self.editCoverImageView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
        }
    }
    
    //MARK: User interaction
    
    @objc private func avatarImageViewTapped() {
        if let handler = self.avatarTapHandler {
            handler(self.avatarImageView)
        }
    }
    
    @objc private func coverImageViewTapped() {
        if let handler = self.coverTapHandler {
            handler(self.headerImageView)
        }
    }
}
