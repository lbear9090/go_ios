//
//  MentionsTextViewTableViewCell.swift
//  Go
//
//  Created by Lucky on 03/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SZMentionsSwift

class MentionsTextViewTableViewCell: TextViewTableViewCell {
    
    var textViewFont: UIFont = Font.regular.withSize(.large)
    
    lazy var mentionsAccessoryView: MentionsAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 55)
        let view = MentionsAccessoryView(frame: frame)
        view.delegate = self
        view.alpha = 0
        return view
    }()
    
    lazy var mentionsListener = SZMentionsListener(mentionTextView: self.textView,
                                                   mentionsManager: self,
                                                   textViewDelegate: self,
                                                   mentionTextAttributes: self.mentionTextAttributes,
                                                   defaultTextAttributes: self.defaultTextAttributes,
                                                   spaceAfterMention: true,
                                                   triggers: ["#"])
    
    var mentionTextAttributes: [AttributeContainer] {
        let font = SZAttribute(attributeName: NSAttributedStringKey.font.rawValue,
                               attributeValue: self.textViewFont)
        
        let textColor = SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue,
                                    attributeValue: UIColor.green)
        
        return [font, textColor]
    }
    
    var defaultTextAttributes: [AttributeContainer] {
        let font = SZAttribute(attributeName: NSAttributedStringKey.font.rawValue,
                               attributeValue: self.textViewFont)

        let textColor = SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue,
                                    attributeValue: UIColor.darkText)
    
        return [font, textColor]
    }
    
    override func setup() {
        super.setup()
        self.textView.font = self.textViewFont
        self.textView.delegate = self.mentionsListener
        self.textView.inputAccessoryView = self.mentionsAccessoryView
    }
    
    func getTags(forString string: String) {
        SHOAPIClient.shared.tags(forTerm: string) { object, error, code in
            if let tags = object as? [TagModel] {
                self.showAccessoryView(tags.count > 0)
                self.mentionsAccessoryView.datasource = tags.map { $0.text }
            }
        }
    }
    
    func showAccessoryView(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.mentionsAccessoryView.alpha = show ? 1 : 0
        }
    }
    
}

extension MentionsTextViewTableViewCell: MentionsManagerDelegate {
    
    func showMentionsListWithString(_ mentionsString: String) {
        self.getTags(forString: mentionsString)
    }
    
    func hideMentionsList() {
        self.showAccessoryView(false)
    }
    
    func didHandleMentionOnReturn() -> Bool {
        return false
    }
    
}

extension MentionsTextViewTableViewCell: MentionsAccessoryViewDelegate {
    
    func didSelectMetion(_ mentionString: String) {
        self.mentionsListener.addMention(MentionCreationModel(text: "#\(mentionString)"))
        self.textViewDidChange(self.textView)
    }

}

extension MentionsTextViewTableViewCell {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "#"
        }
    }
}
