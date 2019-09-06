//
//  TextViewTableViewCell.swift
//  Go
//
//  Created by Lucky on 15/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class TextViewTableViewCell: SHOTableViewCell {
    
    public var textHandler: TextChangeHandler?
    public var textViewSizeChangeHandler: ((UITextView) -> Void)?
    
    public lazy var textView: PlaceholderTextView = {
        let aTextView: PlaceholderTextView = UITextView.newAutoLayout()
        aTextView.isScrollEnabled = false
        aTextView.delegate = self
        aTextView.font = Font.regular.withSize(.medium)
        return aTextView
    }()
    
    public let iconImageView: UIImageView = UIImageView()
    
    private var textViewHeight: CGFloat?
    
    // View Setup
    
    override func setup() {
        super.setup()
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.iconImageView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        self.iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.textView.snp.makeConstraints { (make) in
            if self.iconImageView.image != nil {
                
                make.top.equalTo(self.contentView.snp.topMargin)
                make.right.equalTo(self.contentView.snp.rightMargin)
                make.bottom.equalTo(self.contentView.snp.bottomMargin)
                make.left.equalTo(self.iconImageView.snp.right).offset(12.0)
                
            } else {
                make.edges.equalTo(self.contentView.snp.margins)
            }
        }
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.top.equalTo(self.contentView.snp.topMargin)
        }
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let height = textView.intrinsicContentSize.height
        
        if height != self.textViewHeight {
            self.textViewSizeChangeHandler?(self.textView)
            self.textViewHeight = height
        }
        
        self.textHandler?(self.textView.text ?? "")
        self.layoutIfNeeded()
    }
}
