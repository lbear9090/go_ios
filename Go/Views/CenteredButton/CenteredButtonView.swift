//
//  CenteredButtonView.swift
//  Go
//
//  Created by Lucky on 04/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class CenteredButtonView: SHOView {
    
    let button: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    override func setup() {
        self.addSubview(self.button)
    }
    
    override func applyConstraints() {
        self.button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
