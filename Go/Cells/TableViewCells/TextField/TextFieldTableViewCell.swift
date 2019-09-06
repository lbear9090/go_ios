//
//  TextFieldTableViewCell.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

public typealias TextChangeHandler = (_ text: String) -> Void

class TextFieldTableViewCell: SHOTableViewCell {
    
    public var textHandler: TextChangeHandler?
    
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
        label.addObserver(self,
                          forKeyPath: #keyPath(text),
                          options: [.old, .new],
                          context: nil)
        return label
    }()
    
    var textField: UITextField = {
        var textField = UITextField()
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
        
        self.imageView?.addObserver(self,
                                    forKeyPath: #keyPath(image),
                                    options: .new,
                                    context: nil)
        
        let tapRecognizer = UITapGestureRecognizer(target: self.textField,
                                                   action: #selector(becomeFirstResponder))
        self.contentView.addGestureRecognizer(tapRecognizer)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        self.contentView.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15)
        
        self.label.setContentHuggingPriority(.required, for: .horizontal)
        self.label.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.topMargin)
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
            
            if let imageView = self.imageView,
                imageView.image != nil {
                make.left.equalTo(imageView.snp.right).offset(15.0)
            } else {
                make.edges.equalTo(self.contentView.snp.margins)
            }
        }
    }
    
    @objc func textChanged() {
        self.textHandler?(self.textField.text ?? "")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(text) {
            if let newText = change?[.newKey] as? String, !newText.isEmpty {
                self.textField.textAlignment = .right
            }
            else {
                self.textField.textAlignment = .left
            }
        }
        if keyPath == #keyPath(image) {
            self.layoutIfNeeded()
        }
    }
    
    deinit {
        self.label.removeObserver(self, forKeyPath: #keyPath(text))
        self.imageView?.removeObserver(self, forKeyPath: #keyPath(image))
        NotificationCenter.default.removeObserver(self)
    }
    
}
