//
//  UserProfileHeaderView.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class CurrentUserProfileHeaderView: AvatarHeaderView {
    
    var friendLabelTapHandler: (() -> Void)?
    
    // MARK: - Public properties
    
    let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .trailing
        return stackView
    }()
    
    let friendsCountLabel: UILabel = {
        let config = LabelConfig(textFont: Font.light.withSize(.small),
                                 textAlignment: .right,
                                 textColor: .lightText)
        let label: UILabel = UILabel(with: config)
        return label
    }()
    
    lazy var friendsImageView: UIImageView = {
        let imageView = UIImageView(image: .myFriendsIcon)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(friendLabelTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapRecognizer)
        
        return imageView
    }()
    
    // MARK: - Private properties
    
    private let displayNameLabel: UILabel = {
        let config = LabelConfig(textFont: Font.semibold.withSize(.medium),
                                 textColor: .text)
        let label = UILabel(with: config)
        return label
    }()
    
    private let profileDescriptionLabel: UILabel = {
        let config = LabelConfig(textFont: Font.regular.withSize(.small),
                                 textColor: .text,
                                 numberOfLines: 0)
        let label = UILabel(with: config)
        return label
    }()
    
    private let bottomDivider: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()
    
    // MARK: - View Setup
    
    override func setup() {
        super.setup()        
        self.backgroundColor = .white

        self.addSubview(self.displayNameLabel)
        self.addSubview(self.topStackView)
        self.addSubview(self.profileDescriptionLabel)
        self.addSubview(self.bottomDivider)
        
        self.topStackView.addArrangedSubview(self.friendsImageView)
        self.topStackView.addArrangedSubview(self.friendsCountLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.displayNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.avatarImageView.snp.left)
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(8.0)
            make.right.lessThanOrEqualTo(self.topStackView.snp.left)
        }
        
        self.profileDescriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.displayNameLabel.snp.left)
            make.right.equalTo(self.snp.rightMargin)
            make.top.equalTo(self.displayNameLabel.snp.bottom).offset(8.0)
            make.bottom.equalTo(self.snp.bottomMargin)
        }
        
        self.topStackView.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.rightMargin)
            make.left.greaterThanOrEqualTo(self.avatarImageView.snp.right)
            make.top.equalTo(self.headerImageView.snp.bottom).offset(16.0)
        }
        
        self.bottomDivider.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        self.friendsImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 36.0, height: 36.0))
        }
    }
    
    // MARK: - Configuration
    
    public func populate(with user: UserModel) {
        self.displayNameLabel.text = user.displayName
        self.profileDescriptionLabel.text = user.userDescription
        if let friendCount = user.friendCount {
            self.friendsCountLabel.text = "\(friendCount)"
        }
        
        if let avatarUrlString = user.avatarImage?.mediumUrl {
            self.avatarImageView.kf.setImage(with: URL(string: avatarUrlString),
                                             placeholder: UIImage.avatarPlaceholder)
        }
        
        if let coverUrlString = user.coverImage?.largeUrl {
            self.headerImageView.kf.setImage(with: URL(string: coverUrlString),
                                             placeholder: UIImage.headerPlaceholder)
        }
    }
    
    // MARK: - User interaction
    
    @objc public func friendLabelTapped() {
        self.friendLabelTapHandler?()
    }
    
}
