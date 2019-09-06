//
//  SpinnerCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 10/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SpinnerCollectionViewCell: UICollectionViewCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

}
