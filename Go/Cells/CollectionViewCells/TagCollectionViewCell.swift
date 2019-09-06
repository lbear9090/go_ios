//
//  TagCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 18/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import TagListView

class TagCollectionViewCell: BaseCollectionViewCell {
    
    var tagReference: TagView?
    
    let tagLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.textColor = .white
        label.textAlignment = .center
    
        return label
    }()
    
    private let xImageView = UIImageView(image: .deleteTagIcon)
    
    private let roundedContainer: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .green
        view.clipsToBounds = true
        
        return view
    }()

    override func setup() {
        super.setup()
        self.contentView.addSubview(self.roundedContainer)
        self.roundedContainer.addSubview(self.tagLabel)
        self.roundedContainer.addSubview(self.xImageView)
    }
    
    override func applyConstraints() {
        self.roundedContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.tagLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.left.equalToSuperview().inset(8)
        }
        
        self.xImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(4)
            make.left.equalTo(self.tagLabel.snp.right).offset(4)
            make.centerY.equalTo(self.tagLabel.snp.centerY)
        }
    }
    
    func populate(with tagView: TagView) {
        self.tagReference = tagView
        self.tagLabel.text = tagView.title(for: UIControlState())
        self.roundedContainer.layer.cornerRadius = self.roundedContainer.bounds.height / 2
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundedContainer.layer.cornerRadius = self.roundedContainer.bounds.height / 2
    }
    
}
