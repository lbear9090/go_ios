//
//  UserProfileSectionHeaderView.swift
//  Go
//
//  Created by Lucky on 12/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import OnlyPictures

enum ProfileSegmentedControlType: Int {
    case hosting, attending
    
    static var items: [String] = ["USER_PROFILE_TITLE_HOSTING".localized,
                                  "USER_PROFILE_TITLE_ATTENDING".localized]
    
    var stringValue: String {
        switch self {
        case .hosting:
            return "hosting"
        case .attending:
            return "attending"
        }
    }
}

protocol UserProfileSectionHeaderViewDelegate: AnyObject {
    func didSelectSegmentedControlType(_ type: ProfileSegmentedControlType)
    func didSelectEventCountView()
}

class UserProfileSectionHeaderView: SHOView {
    
    weak var delegate: UserProfileSectionHeaderViewDelegate?
    
    var selectedSegmentType: ProfileSegmentedControlType? {
        return ProfileSegmentedControlType(rawValue: self.segmentControlView.selectedIndex)
    }
    
    private let initalSelectedSegment: ProfileSegmentedControlType
    
    private var avatarImageUrls: [String] = []

    private lazy var segmentControlView: SegmentedControlView = {
        let view: SegmentedControlView = SegmentedControlView.newAutoLayout()
        
        for (i, item) in ProfileSegmentedControlType.items.enumerated() {
            view.segmentedControl.insertSegment(withTitle: item, at: i, animated: false)
        }
        view.segmentedControl.addTarget(self,
                                        action: #selector(segmentedControlChanged(sender:)),
                                        for: .valueChanged)
        
        view.segmentedControl.selectedSegmentIndex = self.initalSelectedSegment.rawValue
        
        return view
    }()
    
    private let eventCountLabel: UILabel = {
        let config = LabelConfig(textFont: Font.bold.withSize(.small),
                                 textColor: .text)
        let label = UILabel(with: config)
        return label
    }()
    
    private let friendsCountLabel: UILabel = {
        let config = LabelConfig(textFont: Font.bold.withSize(.small),
                                 textAlignment: .right,
                                 textColor: .text)
        let label = UILabel(with: config)
        return label
    }()
    
    private lazy var avatarsView: OnlyPictures = {
        let pictures: OnlyHorizontalPictures = OnlyHorizontalPictures.newAutoLayout()
        pictures.dataSource = self
        pictures.backgroundColor = .clear
        pictures.alignment = .right
        return pictures
    }()
    
    private let bottomDivider: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .lightGray
        return view
    }()
    
    init(selectedSegmentType: ProfileSegmentedControlType) {
        self.initalSelectedSegment = selectedSegmentType
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubview(self.segmentControlView)
        self.addSubview(self.eventCountLabel)
        self.addSubview(self.friendsCountLabel)
        self.addSubview(self.avatarsView)
        self.addSubview(self.bottomDivider)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(eventCountViewTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func applyConstraints() {
        self.segmentControlView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44.0)
        }
        
        self.eventCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.eventCountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(self.segmentControlView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        self.friendsCountLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.top.equalTo(self.segmentControlView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        self.avatarsView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.avatarsView.snp.makeConstraints { (make) in
            make.top.equalTo(self.segmentControlView.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(2)
            make.left.equalTo(self.eventCountLabel.snp.right).offset(5)
            make.right.equalTo(self.friendsCountLabel.snp.left).offset(-5)
        }
        
        self.bottomDivider.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
    
    // MARK: - Configuration
    
    func populate(with meta: ProfileEventsMetaModel) {
        self.eventCountLabel.text = String(format: "USER_PROFILE_EVENTS_COUNT".localized, meta.eventCount)
        
        var friendsCountString: String? = nil
        if meta.attendingFriendsCount > 0 {
            friendsCountString = String(format: "USER_PROFILE_FRIENDS_GOING".localized, meta.attendingFriendsCount)
        }
        self.friendsCountLabel.text = friendsCountString
        
        self.avatarImageUrls = meta.attendingFriends.compactMap { user -> String? in
            return user.avatarImage?.smallUrl
        }
        self.avatarsView.isHidden = avatarImageUrls.count == 0
        self.avatarsView.reloadData()
        self.layoutIfNeeded()
        self.avatarsView.layoutIfNeeded()
    }
    
    func setSegmentedControlEnabled(_ enabled: Bool) {
        self.segmentControlView.segmentedControl.isUserInteractionEnabled = enabled
    }
    
    // MARK: - User Action
    
    @objc func segmentedControlChanged(sender: UISegmentedControl) {
        if let selectedType = ProfileSegmentedControlType(rawValue: sender.selectedSegmentIndex) {
            delegate?.didSelectSegmentedControlType(selectedType)
        }
    }
    
    @objc func eventCountViewTapped() {
        self.delegate?.didSelectEventCountView()
    }
}

extension UserProfileSectionHeaderView: OnlyPicturesDataSource {
    
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
