//
//  TagListTableViewCell.swift
//  Go
//
//  Created by Lucky on 22/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import TagListView

class TagListTableViewCell: SHOTableViewCell, TagListViewDelegate {
    
    public var tagSelectedHandler: ((String) -> Void)?
    
    private lazy var tagListView: TagListView = {
        let view = TagListView.configuredView()
        view.alignment = .left
        view.delegate = self
        return view
     }()

    override func setup() {
        super.setup()
        self.selectionStyle = .none
        self.separatorView.isHidden = false
        self.contentView.addSubview(self.tagListView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        self.tagListView.setContentHuggingPriority(.required, for: .vertical)
        self.tagListView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    public func setTags(_ tags: [String]) {
        self.tagListView.removeAllTags()
        self.tagListView.addTags(tags)
        self.layoutIfNeeded()
    }
    
    //MARK: - TagListViewDelegate
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if let tagText = tagView.titleLabel?.text {
            self.tagSelectedHandler?(tagText)
        }
    }

}
