//
//  CircularCountView.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

class CircularCountView: SHOView {
    
    public static let DefaultSize = CGSize(width: 24, height: 24)
    
    private let countLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.extraSmall)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        self.backgroundColor = .green
        self.addSubview(countLabel)
    }
    
    override func applyConstraints() {
        
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(0.707)
            make.height.equalTo(self.countLabel.snp.width)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    public var count: Int? {
        didSet {
            if let count = count {
                var countStr = "\(count)"
                if count > 999 {
                    let minCount: Double = Double(count)/1000.0
                    let floorCount = floor(minCount)
                    countStr = "\(Int(floorCount))k"
                    if minCount.remainder(dividingBy: 1.0) != 0 {
                        countStr.append("+")
                    }
                }
                self.countLabel.text = countStr
                self.isHidden = false
            } else {
                self.countLabel.text = nil
                self.isHidden = true
            }
        }
    }
}
