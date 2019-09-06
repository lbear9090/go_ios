//
//  SwitchTableViewCell.swift
//  Go
//
//  Created by Lucky on 26/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SwitchTableViewCell: SHOTableViewCell {
    
    var switchHandler: ((Bool) -> Void)?
    
    let label: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.large)
        label.textColor = .darkText
        return label
    }()
    
    lazy var cellSwitch: UISwitch = {
        let swtch = UISwitch()
        swtch.onTintColor = .green
        swtch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return swtch
    }()
    
    override func setup() {
        super.setup()
        self.selectionStyle = .none
        self.accessoryView = self.cellSwitch
        self.contentView.addSubview(self.label)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.label.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.right.lessThanOrEqualTo(self.contentView.snp.rightMargin)
            make.centerY.equalToSuperview()
        }
        
    }
    
    //MARK: - User interaction
    
    @objc private func switchToggled(_ sender: UISwitch) {
        if let handler = self.switchHandler {
            handler(sender.isOn)
        }
    }
    
}
