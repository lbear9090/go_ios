//
//  SectionHeaderView.swift
//  Go
//
//  Created by Lucky on 22/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import OnlyPictures

private let AvatarsViewSize = CGSize(width: 40, height: 24)

class SectionHeaderView: SHOView, SHOReusableIdentifier {
    
    var didApplyConstraints = false
    
    let leftLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold.withSize(.small)
        label.textColor = .darkText
        return label
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = Font.semibold.withSize(.small)
        label.textColor = .darkText
        return label
    }()
    
    var avatarImageUrls: [String] = [] {
        didSet {
            self.avatarsView.isHidden = avatarImageUrls.count == 0
            self.avatarsView.reloadData()
            self.avatarsView.layoutIfNeeded()
        }
    }
    
    private lazy var avatarsView: OnlyPictures = {
        let pictures: OnlyHorizontalPictures = OnlyHorizontalPictures.newAutoLayout()
        pictures.frame = CGRect(origin: .zero, size: AvatarsViewSize)
        pictures.dataSource = self
        pictures.backgroundColor = .clear
        pictures.alignment = .right
        return pictures
    }()
    
    override func setup() {
        self.addSubview(self.leftLabel)
        self.addSubview(self.avatarsView)
        self.addSubview(self.rightLabel)
    }
    
    override func updateConstraints() {
        if !didApplyConstraints {
            self.applyConstraints()
            self.didApplyConstraints = true
        }
        super.updateConstraints()
    }
    
    override func applyConstraints() {
        self.leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(self.avatarsView.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        self.rightLabel.snp.makeConstraints { make in
            make.left.equalTo(self.avatarsView.snp.right).offset(8)
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        self.avatarsView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.avatarsView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(2)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview().inset(2)
        }
    }
}

// MARK: - Only Pictures Delegate

extension SectionHeaderView: OnlyPicturesDataSource {
    
    func numberOfPictures() -> Int {
        return self.avatarImageUrls.count
    }
    
    func pictureViews(index: Int) -> UIImage {
        return .roundAvatarPlaceholder
    }
    
    func pictureViews(_ imageView: UIImageView, index: Int) {
        if let imageUrl = URL(string: avatarImageUrls[index]) {
            imageView.kf.setImage(with: imageUrl, placeholder: UIImage.roundAvatarPlaceholder)
        }
    }
}
