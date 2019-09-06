//
//  ButtonView.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol ButtonViewDelegate: class {
    func buttonView(_ view: ButtonView, didSelect button: UIButton)
}

private let Inset: CGFloat = 8

class ButtonView: SHOView {

    weak var delegate: ButtonViewDelegate?
    
    var height = Stylesheet.buttonHeight

    lazy var button: UIButton = {
        var button = UIButton(with: self.config)
        button.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
        return button
    }()
    
    var config: ButtonConfig = .action {
        didSet {
            self.button.setConfig(config)
        }
    }
    
    var title: String = "" {
        didSet {
            self.button.setTitle(title, for: .normal)
        }
    }
    
    override func setup() {
        super.setup()
        self.addSubview(self.button)
    }
    
    override func applyConstraints() {
        self.layoutMargins = UIEdgeInsetsMake(Inset, Inset, Inset, Inset)
        
        self.button.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.margins)
            make.height.equalTo(self.height)
        }
    }
    
    @objc private func buttonTap(_ sender: UIButton) {
        self.delegate?.buttonView(self, didSelect: sender)
    }
    
}
