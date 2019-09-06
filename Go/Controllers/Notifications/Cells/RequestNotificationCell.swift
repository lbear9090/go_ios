//
//  RequestNotificationCell.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

typealias RequestActionHandler = (_ accept: Bool) -> Void
private let ButtonSize = CGSize(width: 24.0, height: 24.0)

class RequestNotificationCell: NotificationCell {
    
    public var actionHandler: RequestActionHandler?
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.acceptRequest, for: .normal)
        button.addTarget(self,
                         action: #selector(acceptFriendRequest),
                         for: .touchUpInside)
        return button
    }()
    
    lazy var rejectButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.rejectRequest, for: .normal)
        button.addTarget(self,
                         action: #selector(rejectFriendRequest),
                         for: .touchUpInside)
        return button
    }()
    
    let buttonsStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()
    
    override func setup() {
        super.setup()
        
        self.contentView.addSubview(self.buttonsStackView)
        self.buttonsStackView.addArrangedSubview(self.confirmButton)
        self.buttonsStackView.addArrangedSubview(self.rejectButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.buttonsStackView.snp.makeConstraints { make in
            make.left.equalTo(self.labelStackView.snp.right).offset(8.0)
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.centerY.equalToSuperview()
        }
        
        self.confirmButton.snp.makeConstraints { make in
            make.size.equalTo(ButtonSize)
        }
        
        self.rejectButton.snp.makeConstraints { make in
            make.size.equalTo(ButtonSize)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.makeCircular()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.enableButtons(true)
    }
    
    //MARK: - User Interaction
    
    @objc func acceptFriendRequest() {
        if let handler = self.actionHandler {
            handler(true)
        }
    }
    
    @objc func rejectFriendRequest() {
        if let handler = self.actionHandler {
            handler(false)
        }
    }
    
    func enableButtons(_ enabled: Bool) {
        self.confirmButton.isEnabled = enabled;
        self.rejectButton.isEnabled = enabled;
    }
    
}
