//
//  BaseCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell, SHOReusableIdentifier {
    
    private var didSetupConstraints: Bool = false
    
    var leftSeparatorMargin: Float = 0.0
    var rightSeparatorMargin: Float = 0.0
    
    let separatorView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.tableViewCellSeparator
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if !didSetupConstraints {
            self.applyConstraints()
            self.didSetupConstraints = true
        }
    }

    // MARK: - ViewSetup
    
    override func setup() {
        self.backgroundColor = .tableViewCellBackground
        self.addSubview(self.separatorView)
        self.separatorView.isHidden = true
    }
    
    override func applyConstraints() {
        self.separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(self.leftSeparatorMargin)
            make.right.equalToSuperview().inset(self.rightSeparatorMargin)
            make.height.equalTo(Stylesheet.tableViewCellSeparatorHeight)
        }
    }
}
