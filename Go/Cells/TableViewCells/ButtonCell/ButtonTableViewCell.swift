//
//  ButtonTableViewCell.swift
//  Go
//
//  Created by Lucky on 31/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class ButtonTableViewCell: SHOTableViewCell {

    var actionHandler: ((ButtonTableViewCell) -> Void)?
    
    lazy var button: UIButton = {
        let btn = UIButton(with: .action)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - View Setup
    
    override func setup() {
        super.setup()
        
        self.contentView.addSubview(self.button)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.contentView.layoutMargins = UIEdgeInsetsMake(8.0, 16.0, 8.0, 16.0)
        
        self.button.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView.snp.margins).priority(.high)
            make.height.equalTo(44.0)
        }
    }
    
    // MARK: - User Action
    
    @objc func buttonTapped() {
        self.actionHandler?(self)
    }

}
