//
//  TagListView+Configuration.swift
//  Go
//
//  Created by Killian Kenny on 18/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import TagListView

extension TagListView {
    
    static let DefaultInset: CGFloat = 30.0
    
    static func configuredView() -> TagListView {
        let tagListView = TagListView()

        tagListView.alignment = .center
        tagListView.paddingX = 6
        tagListView.paddingY = 4
        tagListView.marginX = 5
        tagListView.marginY = 5
        tagListView.cornerRadius = 11
        tagListView.textFont = Font.regular.withSize(.medium)
        
        tagListView.tagBackgroundColor = .unselectedTag
        tagListView.textColor = .white
        
        tagListView.tagSelectedBackgroundColor = .selectedTag
        tagListView.selectedTextColor = .white
        
        return tagListView
    }
    
    func addTags(_ tags: [TagModel], withSelected selectedTags: [TagView]) {
        self.addTags(tags.map { (model) -> String in
            return model.text
        }).enumerated().forEach { index, tagView in
            tagView.tag = tags[index].id
            tagView.isSelected = selectedTags.contains {
                return $0 == tagView
            }
        }
    }
    
}

extension TagView {

    static func == (lhs: TagView, rhs: TagView) -> Bool {
        if let leftTitle = lhs.titleLabel?.text {
            return leftTitle == rhs.titleLabel?.text
        } else {
            return false
        }
    }
    
    static func != (lhs: TagView, rhs: TagView) -> Bool {
        return !(lhs == rhs)
    }

}
