//
//  TagTableViewCell.swift
//  Go
//
//  Created by Lucky on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SearchTableViewCell: SHOTableViewCell {
    
    private let labelStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.large)
        label.textColor = .darkText
        return label
    }()
    
    let detailLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.textColor = .lightText
        return label
    }()

    override func setup() {
        super.setup()
        self.separatorView.isHidden = false
        
        self.contentView.addSubview(self.labelStackView)
        
        self.labelStackView.addArrangedSubview(self.titleLabel)
        self.labelStackView.addArrangedSubview(self.detailLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(self.labelStackView.snp.left)
        }
        
        self.labelStackView.snp.makeConstraints { make in
            if let imageView = self.imageView {
                make.left.equalTo(imageView.snp.right).offset(16)
            } else {
                make.left.equalToSuperview()
            }
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
    
}
