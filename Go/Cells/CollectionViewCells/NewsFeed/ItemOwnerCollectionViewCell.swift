//
//  ItemOwnerCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let ImageViewSize = CGSize(width: 28.0, height: 28.0)
private let Spacing: CGFloat = 8.0

protocol ItemOwnerCollectionViewCellDelegate: class {
    func didSelectOptionsButton()
}

class ItemOwnerCollectionViewCell: BaseCollectionViewCell {
    
    public weak var delegate: ItemOwnerCollectionViewCellDelegate?
    
    public var showShadow: Bool = false {
        didSet {
            if showShadow {
                self.addTopShadow()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }
    
    private let avatarImageView = UIImageView(frame: CGRect(origin: .zero, size: ImageViewSize))
    
    private let unameLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.medium)
        label.textColor = .darkText
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(.actionButton, for: .normal)
        button.addTarget(self,
                         action: #selector(didTapOptionsButton),
                         for: .touchUpInside)
        return button
    }()
    
    let topSeparatorView: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()
    
    //MARK: View setup
    
    override func setup() {
        super.setup()
        
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.unameLabel)
        self.contentView.addSubview(self.actionButton)
        self.contentView.addSubview(self.topSeparatorView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(ImageViewSize)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Spacing)
        }
        
        self.unameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.avatarImageView.snp.right).offset(Spacing)
            make.right.equalTo(self.actionButton.snp.left).inset(-Spacing)
        }
        
        self.actionButton.setContentHuggingPriority(.required, for: .horizontal)
        self.actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(Spacing)
        }
        
        self.topSeparatorView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.makeCircular(.scaleAspectFill)
    }
    
    //MARK: Setters
    
    public func populate(with user: UserModel) {
        unameLabel.text = user.displayName
        if let avatarUrl = user.avatarImage?.mediumUrl {
            avatarImageView.kf.setImage(with: URL(string: avatarUrl),
                                        placeholder: UIImage.roundAvatarPlaceholder)
        }
    }
    
    @objc private func didTapOptionsButton() {
        self.delegate?.didSelectOptionsButton()
    }
}
