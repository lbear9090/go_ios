//
//  AuthTextFieldView.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let Margin: CGFloat = 10.0
private let SideMargin: CGFloat = 30.0

class AuthTextFieldView: SHOView {
    
    static let Height: CGFloat = 50.0
    
    private(set) var textField: UITextField = UITextField.newAutoLayout()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightText
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.semibold.withSize(.extraSmall)
        label.textColor = .lightText
        return label
    }()
    
    var placeholder: String? {
        get {
            return self.descriptionLabel.text
        }
        set {
            self.descriptionLabel.text = newValue?.uppercased()
        }
    }
    
    convenience init(withTFDelegate delegate: UITextFieldDelegate) {
        self.init()
        self.textField.delegate = delegate
        commonInit()
    }
    
    convenience init(withTextField textField: UITextField) {
        self.init()
        self.textField = textField
        commonInit()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setupTextfield(textField: self.textField)
        self.addSubview(self.textField)
    }
    
    private func setupTextfield(textField: UITextField) {
        textField.font = Font.regular.withSize(.large)
        textField.textColor = .authTextField
        textField.tintColor = .green
    }
    
    override func setup() {
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.underlineView)
    }
    
    override func applyConstraints() {
        self.layoutMargins = UIEdgeInsets(top: Margin, left: SideMargin,
                                          bottom: Margin, right: SideMargin)
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(self.snp.leftMargin)
            make.bottom.equalTo(self.textField.snp.top).offset(-12)
        }
    
        self.textField.snp.makeConstraints { make in
            make.left.equalTo(self.snp.leftMargin)
            make.right.equalTo(self.snp.rightMargin)
            make.bottom.equalTo(self.underlineView.snp.top).offset(-4)
        }
        
        self.underlineView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.leftMargin)
            make.right.equalTo(self.snp.rightMargin)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
