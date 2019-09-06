//
//  PickerTextFieldTableViewCell.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

class PickerTextFieldTableViewCell: SHOTableViewCell {
    
    var stackView: UIStackView = {
        var stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        return stackView
    }()
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.font = Font.regular.withSize(.large)
        label.textColor = .black
        label.addObserver(self, forKeyPath: "text", options: [.old, .new], context: nil)
        return label
    }()
    
    var textField: PickerViewTextField = {
        var textField = PickerViewTextField()
        textField.font = Font.regular.withSize(.large)
        textField.textColor = .text
        return textField
    }()
    
    override func setup() {
        super.setup()
        self.selectionStyle = .none
        self.leftSeparatorMargin = 15.0
        
        self.stackView.addArrangedSubview(self.label)
        self.stackView.addArrangedSubview(self.textField)
        
        self.contentView.addSubview(self.stackView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self.textField,
                                                   action: #selector(becomeFirstResponder))
        self.contentView.addGestureRecognizer(tapRecognizer)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        self.contentView.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15)
        
        self.label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.stackView.snp.makeConstraints { make in
            if let imageView = self.imageView,
                let _ = self.imageView?.image {
                make.top.equalTo(self.contentView.snp.topMargin)
                make.right.equalTo(self.contentView.snp.rightMargin)
                make.bottom.equalTo(self.contentView.snp.bottomMargin)
                make.left.equalTo(imageView.snp.right).offset(15.0)
            }
            else {
                make.edges.equalTo(self.contentView.snp.margins)
            }
        }
        
        self.label.setContentHuggingPriority(.required, for: .horizontal)
        self.label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            if let newText = change?[.newKey] as? String, !newText.isEmpty {
                self.textField.textAlignment = .right
            }
            else {
                self.textField.textAlignment = .left
            }
            self.layoutIfNeeded()
        }
    }
}
