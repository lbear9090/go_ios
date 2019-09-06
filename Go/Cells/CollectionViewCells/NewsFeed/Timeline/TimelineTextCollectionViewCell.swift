//
//  TimelineTextCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 09/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class TimelineTextCollectionViewCell: BaseCollectionViewCell {
    
    let label: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.numberOfLines = 0
        label.backgroundColor = .pinkRed
        label.textColor = .white
        label.font = Font.semibold.withSize(.large)
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        self.contentView.addSubview(self.label)
    }
    
    override func applyConstraints() {
        self.label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
