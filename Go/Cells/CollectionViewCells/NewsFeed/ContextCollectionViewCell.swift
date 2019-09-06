//
//  ContextCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Kingfisher

private let ImageViewSize = CGSize(width: 24.0, height: 24.0)

class ContextCollectionViewCell: BaseCollectionViewCell {
    
    private let topSeparatorView: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()
    
    private let imageView = UIImageView(frame: CGRect(origin: .zero, size: ImageViewSize))
    private let label = UILabel()
    
    //MARK: View setup
    
    override func setup() {
        super.setup()
        self.addTopShadow()
        
        self.contentView.addSubview(self.topSeparatorView)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.label)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.topSeparatorView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(ImageViewSize)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
        
        self.label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.imageView.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
        }
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.makeCircular(.scaleAspectFill)
    }
    
    //MARK: Setters
    
    public func populate(with context: FeedItemContextModel) {
        
        let actorName = context.message.actor
        let action = context.message.action
        let text = (actorName + " ").attributedString(with: [.font: Font.bold.withSize(.small)])
        text.append(action.attributedString(with: [.font: Font.regular.withSize(.small)]))
        self.label.attributedText = text
        
        if let avatarUrl = context.actor.avatarImage?.smallUrl {
            imageView.kf.setImage(with: URL(string: avatarUrl),
                                  placeholder: UIImage.roundAvatarPlaceholder)
        }
    }

}
