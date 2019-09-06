//
//  MentionCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 04/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let ImageViewDimension = 30

class MentionCollectionViewCell: BaseCollectionViewCell {
    
    let textLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.numberOfLines = 1
        return label
    }()
    
    let imageView = UIImageView(image: .searchHashTag)
    
    let rightDividerView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .green
        return view
    }()
    
    override func setup() {
        self.contentView.addSubview(self.textLabel)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.rightDividerView)
    }
    
    override func applyConstraints() {
        self.textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalTo(self.contentView.snp.rightMargin)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(ImageViewDimension)
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.right.equalTo(self.textLabel.snp.left)
            make.centerY.equalToSuperview()
        }
        
        self.rightDividerView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let labelWidth = self.textLabel.intrinsicContentSize.width
        let imageWidth = CGFloat(ImageViewDimension)
        let leftMargin = contentView.layoutMargins.left
        let rightMargin = contentView.layoutMargins.right

        layoutAttributes.frame.size.width = leftMargin + imageWidth + labelWidth + rightMargin
        return layoutAttributes
    }
    
}
