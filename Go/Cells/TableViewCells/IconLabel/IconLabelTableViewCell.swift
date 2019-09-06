//
//  IconLabelTableViewCell.swift
//  Go
//
//  Created by Lucky on 22/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class IconLabelTableViewCell: SHOTableViewCell {
    
    private let containerView: UIView = UIView.newAutoLayout()

    let iconLabel: IconLabel = {
        let label = IconLabel(frame: .zero)
        label.font = Font.regular.withSize(.small)
        label.textColor = .darkText
        return label
    }()
    
    let subLabel: UILabel = {
        let config = LabelConfig(textFont: Font.regular.withSize(.extraSmall),
                                 textColor: .lightText,
                                 numberOfLines: 0)
        let label: UILabel = UILabel(with: config)
        return label
    }()
    
    let loadingSkeleton: UIView = {
        let skeleton = UIView()
        skeleton.layer.cornerRadius = 3
        skeleton.clipsToBounds = true
        skeleton.isHidden = true
        return skeleton
    }()
    
    override func setup() {
        self.contentView.addSubview(self.containerView)
        self.containerView.addSubview(self.iconLabel)
        self.containerView.addSubview(self.subLabel)
        self.containerView.addSubview(self.loadingSkeleton)
    }
    
    override func applyConstraints() {
        
        self.contentView.layoutMargins = UIEdgeInsetsMake(5.0, 16.0, 5.0, 16.0)
        
        self.containerView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView.snp.margins)
        }
        
        self.iconLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.subLabel.snp.top)
        }
        
        self.subLabel.snp.makeConstraints { make in
            make.left.equalTo(self.iconLabel.iconImageView.snp.right).offset(5)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.loadingSkeleton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 16))
        }
        
        self.subLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.subLabel.setContentHuggingPriority(.required, for: .vertical)
        
    }
    
    func animateLoader() {
        
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = contentView.bounds
        backgroundGradientLayer.colors = [UIColor.skeletonColor2.cgColor, UIColor.skeletonColor2.cgColor]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let gradientChangeLocation = CABasicAnimation(keyPath: "locations")
        gradientChangeLocation.duration = 2
        gradientChangeLocation.toValue = [0.0, 0.7]
        gradientChangeLocation.fillMode = kCAFillModeForwards
        gradientChangeLocation.isRemovedOnCompletion = false
        gradientChangeLocation.repeatCount = .infinity
        backgroundGradientLayer.add(gradientChangeLocation, forKey: "locationsChange")
        
        let gradientColors = [UIColor.skeletonColor1.cgColor, UIColor.skeletonColor2.cgColor]
        
        let gradientChangeColor = CABasicAnimation(keyPath: "colors")
        gradientChangeColor.duration = 2
        gradientChangeColor.toValue = gradientColors
        gradientChangeColor.fillMode = kCAFillModeForwards
        gradientChangeColor.isRemovedOnCompletion = false
        gradientChangeColor.repeatCount = .infinity
        backgroundGradientLayer.add(gradientChangeColor, forKey: "colorChange")
        
        loadingSkeleton.layer.addSublayer(backgroundGradientLayer)
    }
    
}
