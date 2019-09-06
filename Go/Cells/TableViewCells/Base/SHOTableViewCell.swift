//
//  SHOTableViewCell.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class SHOTableViewCell: UITableViewCell {
    
    private var didSetupConstraints: Bool = false
    
    var leftSeparatorMargin: Float = 0.0
    var rightSeparatorMargin: Float = 0.0
    
    let topSeparatorView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.tableViewCellSeparator
        return view
    }()
    
    let separatorView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.tableViewCellSeparator
        return view
    }()
    
    override required init(style: UITableViewCellStyle = .default, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
        self.contentView.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
}

// MARK: - ViewSetup

extension SHOTableViewCell {
    
    override func setup() {
        self.backgroundColor = .tableViewCellBackground
        self.textLabel?.font = Font.regular.withSize(.large)
        self.textLabel?.textColor = .darkText
        self.addSubview(self.topSeparatorView)
        self.addSubview(self.separatorView)
        
        self.topSeparatorView.isHidden = true
    }
    
    override func applyConstraints() {
        self.topSeparatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(self.leftSeparatorMargin).priority(.medium)
            make.right.equalToSuperview().inset(self.rightSeparatorMargin)
            make.height.equalTo(Stylesheet.tableViewCellSeparatorHeight)
        }
        
        self.separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(self.leftSeparatorMargin).priority(.medium)
            make.right.equalToSuperview().inset(self.rightSeparatorMargin)
            make.height.equalTo(Stylesheet.tableViewCellSeparatorHeight)
        }
    }
}

extension SHOTableViewCell: SHOReusableTableViewCell { }

