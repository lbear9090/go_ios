//
//  IdentificationImageTableViewCell.swift
//  Go
//
//  Created by Lucky on 15/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

class IdentificationImageTableViewCell: SHOTableViewCell {
    
    let idLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.large)
        return label
    }()
    
    private let idImageView: UIImageView = {
        let imageView: UIImageView = UIImageView.newAutoLayout()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var imageViewTopConstraint: Constraint?
    
    override func setup() {
        super.setup()
        self.contentView.addSubview(self.idLabel)
        self.contentView.addSubview(self.idImageView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        self.contentView.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15)
        
        self.idLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.left.equalTo(self.contentView.snp.leftMargin)
        }
        
        self.idImageView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(200)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
            
            let offset = idImageView.image != nil ? 15 : 0
            make.top.equalTo(self.idLabel.snp.bottom).offset(offset)
        }
        
        idImageView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    public func setImage(_ image: UIImage?) {
        self.idImageView.image = image
    }

}
