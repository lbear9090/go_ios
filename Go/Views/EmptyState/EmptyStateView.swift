//
//  EmptyStateView.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

class EmptyStateView: SHOView {
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = image ?? .emptyState
        
        return imageView
    }()
    
    let label: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.large)
        label.textColor = .green
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func setup() {
        self.addSubview(self.imageView)
        self.addSubview(self.label)
    }
    
    override func applyConstraints() {
        
        self.imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.75)
        }
        
        self.label.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16.0)
        }
    }
    
}
