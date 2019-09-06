//
//  PlaceholderTextField.swift
//  Go
//
//  Created by Lucky on 21/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    override var text: String! {
        didSet {
            self.placeholderLabel.isHidden = !(self.text == nil || self.text.isEmpty)
        }
    }
    
    override var font: UIFont? {
        didSet {
            self.placeholderLabel.font = font
            placeholderLayoutDidChange()
        }
    }
    
    var placeholder: String? {
        didSet {
            self.placeholderLabel.text = placeholder
            placeholderLayoutDidChange()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            self.placeholderLabel.textAlignment = textAlignment
            placeholderLayoutDidChange()
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .lightGray
        label.font = self.font
        label.textAlignment = self.textAlignment
        
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.addSubview(self.placeholderLabel)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged),
                                               name: .UITextViewTextDidChange,
                                               object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let placeholderSize = placeholderLabel.bounds.size
        placeholderLabel.frame = CGRect(x: textContainerInset.left + 5,
                                        y: textContainerInset.top,
                                        width: placeholderSize.width,
                                        height: placeholderSize.height)
    }
    
    private func placeholderLayoutDidChange() {
        self.placeholderLabel.sizeToFit()
        setNeedsLayout()
    }
    
    @objc private func textChanged() {
        self.placeholderLabel.isHidden = !(self.text == nil || self.text.isEmpty)
    }
}
