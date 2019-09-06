//
//  IconLabel.swift
//  Go
//
//  Created by Lucky on 18/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class IconLabel: UILabel {
    
    let iconImageView = UIImageView()
    var imageViewSize: CGSize?
    
    init(icon: UIImage) {
        super.init(frame: .zero)
        self.commonInit()
        self.iconImageView.image = icon
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.iconImageView)
    }
    
    override func layoutSubviews() {
        let imageViewSize = self.imageViewSize ?? CGSize(width: 16, height: 16)
        let diff = self.frame.height - imageViewSize.height
        
        self.iconImageView.frame = CGRect(origin: CGPoint(x: 0, y: diff/2),
                                          size: imageViewSize)
    }
    
    override func drawText(in rect: CGRect) {
        let leftInset = self.iconImageView.bounds.width + 5
        let insets = UIEdgeInsets.init(top: 0, left: leftInset, bottom: 0, right: 5)
        
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        let imageSize = self.imageViewSize ?? CGSize(width: 16, height: 16)
        
        size.width = size.width + imageSize.width + 10
        size.height = max(size.height, imageSize.height)
        
        return size
    }
}
