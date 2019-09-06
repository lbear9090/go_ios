//
//  TimelineCommentCountCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 07/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class TimelineCommentCountCollectionViewCell: BaseCollectionViewCell {
    
    private let countLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.textColor = .lightText
        return label
    }()
    
    var count: Int? {
        didSet {
            if let count = count {
                self.countLabel.text = String(format: "COMMENTS_VIEW_ALL".localized, count)
            } else {
                self.countLabel.text = nil
            }
        }
    }
    
    override func setup() {
        super.setup()
        self.contentView.addSubview(self.countLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        self.countLabel.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView.snp.margins)
        }
    }
    
}
