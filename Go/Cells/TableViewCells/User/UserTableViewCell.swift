//
//  UserTableViewCell.swift
//  Go
//
//  Created by Lucky on 22/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let AvatarSize = CGSize(width: 32, height: 32)

class UserTableViewCell: SHOTableViewCell {
    
    //MARK: Properties
    var attendingIconTappedHandler: (() -> Void)?
    
    private let avatarBorderView = UIView()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: AvatarSize))
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.image = .roundAvatarPlaceholder
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let invitedIconImageView: UIImageView = {
        let imageView: UIImageView = UIImageView.newAutoLayout()
        imageView.image = .invitedIcon
        imageView.isHidden = true
        return imageView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.large)
        label.textColor = .darkText
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.small)
        label.textColor = .lightText
        return label
    }()

    private let horizontalStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0
        return stackView
    }()
    
    private let hostingView: CountImageView = {
        let view = CountImageView()
        view.image = .hosting
        return view
    }()
    
    private lazy var attendingView: CountImageView = {
        let view = CountImageView()
        view.image = .attending
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(showAttendingEvents))
        view.addGestureRecognizer(tapGR)
        
        return view
    }()
    
    //MARK: - Convenience Setters
    
    var avatarBorderColor: UIColor = .clear {
        didSet {
            self.avatarBorderView.backgroundColor = avatarBorderColor
        }
    }
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        self.separatorView.isHidden = false
        
        self.contentView.addSubview(self.avatarBorderView)
        self.avatarBorderView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.invitedIconImageView)
        self.contentView.addSubview(self.labelStackView)
        self.contentView.addSubview(self.horizontalStackView)
        
        self.labelStackView.addArrangedSubview(self.nameLabel)
        self.labelStackView.addArrangedSubview(self.detailLabel)
        
        self.horizontalStackView.addArrangedSubview(self.hostingView)
        self.horizontalStackView.addArrangedSubview(self.attendingView)
    }
    
    override func applyConstraints() {
        
        self.separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(self.labelStackView.snp.left)
            make.right.equalToSuperview().inset(self.rightSeparatorMargin)
            make.height.equalTo(Stylesheet.tableViewCellSeparatorHeight)
        }
        
        self.avatarBorderView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(AvatarSize)
        }
        
        self.avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1)
        }
        
        self.invitedIconImageView.snp.makeConstraints { make in
            make.top.right.equalTo(self.avatarBorderView)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        self.labelStackView.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImageView.snp.right).offset(16)
            make.right.equalTo(self.horizontalStackView.snp.left)
            make.centerY.equalToSuperview()
        }
        
        self.horizontalStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.width.equalTo(90)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.makeCircular()
        self.avatarBorderView.layer.cornerRadius = AvatarSize.width / 2
        self.avatarBorderView.clipsToBounds = true
    }
    
    //MARK: - Configuration
    
    public func populate(with user: UserModel) {
        self.nameLabel.text = user.displayName
        self.hostingView.count = user.eventCount
        self.attendingView.count = user.attendingEventCount
        
        if let smallUrlString = user.avatarImage?.smallUrl {
            self.avatarImageView.kf.setImage(with: URL(string: smallUrlString),
                                             placeholder: UIImage.roundAvatarPlaceholder)
        }
    }
    
    //MARK: - User actions
    
    @objc private func showAttendingEvents() {
        self.attendingIconTappedHandler?()
    }
}

fileprivate class CountImageView: SHOView {
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.extraSmall)
        label.textColor = .green
        label.text = "0"
        return label
    }()
    
    private let imageView = UIImageView()
    
    public var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
    
    public var count: Int? {
        didSet {
            if let count = count {
                self.countLabel.text = String(describing: count)
            } else {
                self.countLabel.text = nil
            }
        }
    }
    
    override func setup() {
        self.addSubview(self.countLabel)
        self.addSubview(self.imageView)
    }
    
    override func applyConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().inset(8.0)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        self.countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.countLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(4)
            make.left.equalTo(self.imageView.snp.right)
            make.centerY.equalTo(self.imageView.snp.top)
        }
    }
}
