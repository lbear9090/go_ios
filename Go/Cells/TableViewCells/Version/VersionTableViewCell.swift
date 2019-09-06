//
//  VersionTableViewCell.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

class VersionTableViewCell: SHOTableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.medium)
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        super.setup()
        self.separatorView.isHidden = true
        self.selectionStyle = .none
        self.contentView.addSubview(self.titleLabel)
        
        self.titleLabel.text = SHOUtils.versionBuildString
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView.snp.margins)
        }
    }
    
}

