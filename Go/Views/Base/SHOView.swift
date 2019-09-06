//
//  SHOView.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import SnapKit

class SHOView: UIView {
    
    private var didSetupConstraints: Bool = false
    
    convenience init(size: CGSize) {
        self.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetupConstraints {
            self.applyConstraints()
            self.didSetupConstraints = true
        }
    }
    
}
