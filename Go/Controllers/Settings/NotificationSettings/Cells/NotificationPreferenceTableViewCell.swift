//
//  NotificationPreferenceTableViewCell.swift
//  Go
//
//  Created by Lucky on 26/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class NotificationPreferenceTableViewCell: SwitchTableViewCell {
    
    var infoButtonTapHandler: (() -> Void)?
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: UIButtonType.infoLight)
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        return button
    }()

    override func setup() {
        super.setup()
        self.tintColor = .green
        self.contentView.addSubview(self.infoButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.label.snp.remakeConstraints { make in
            make.left.equalTo(self.infoButton.snp.right).offset(10)
            make.right.lessThanOrEqualTo(self.contentView.snp.rightMargin)
            make.centerY.equalToSuperview()
        }
        
        self.infoButton.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.centerY.equalToSuperview()
        }
        
    }
    
    //MARK: - User interaction
    
    @objc private func infoButtonTapped() {
        if let handler = self.infoButtonTapHandler {
            handler()
        }
    }
    
}
