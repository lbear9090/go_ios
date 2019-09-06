//
//  EventActionsCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let Spacing: CGFloat = 8.0

protocol TimelineActionsCollectionViewCellDelegate {
    func didTapCommentButton()
    func showError(withText text: String)
}

class TimelineActionsCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    public var showShadow: Bool = false {
        didSet {
            if showShadow {
                self.addBottomShadow()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }
    
    var delegate: TimelineActionsCollectionViewCellDelegate?
    private var timelineItem: TimelineModel?
    
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.semibold.withSize(.small)
        label.textColor = .darkText
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.commentsButton, for: .normal)
        button.addTarget(self,
                         action:#selector(commentButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.likeButton, for: .normal)
        button.addTarget(self,
                         action: #selector(likeButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private let commentsCountLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.textColor = .lightText
        label.text = "0"
        return label
    }()
    
    private let likesCountLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.textColor = .lightText
        label.text = "0"
        return label
    }()
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()

        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.commentButton)
        self.contentView.addSubview(self.likeButton)
        self.contentView.addSubview(self.commentsCountLabel)
        self.contentView.addSubview(self.likesCountLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(Spacing)
            make.right.lessThanOrEqualTo(self.commentButton.snp.left).offset(-Spacing)
        }
        
        self.commentButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.commentsCountLabel.snp.left).offset(-Spacing/2)
        }
        
        self.commentsCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.likeButton.snp.left).offset(-Spacing)
        }
        
        self.likeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.likesCountLabel.snp.left).offset(-Spacing/2)
        }
        
        self.likesCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(Spacing)
        }
    }
    
    //MARK: - Configure cell
    
    public func populate(withTimeline timeline: TimelineModel) {
        self.timelineItem = timeline
        
        self.titleLabel.text = timeline.associatedEventTitle
        
        self.likesCountLabel.text = String(describing: timeline.likeCount)
        self.commentsCountLabel.text = String(describing: timeline.commentCount)
        
        self.setLikeButtonImage(for: timeline.liked)
    }
    
    //MARK: - User interactions
    
    @objc private func commentButtonTapped() {
        delegate?.didTapCommentButton()
    }
    
    @objc private func likeButtonTapped(_ sender: UIButton) {
        if let timeline = self.timelineItem {
            self.setLikeButtonImage(for: !timeline.liked)
            self.toggleLikedState(for: timeline)
        }
    }
    
    //MARK: - Helpers
    
    private func setLikeButtonImage(for likedState: Bool) {
        let likeButtonIcon: UIImage = likedState ? .unlikeButton : .likeButton
        self.likeButton.setImage(likeButtonIcon, for: UIControlState())
    }
    
    private func toggleLikedState(for timeline: TimelineModel) {
        if timeline.liked {
            self.likesCountLabel.text = String(describing: timeline.likeCount - 1)
            
            SHOAPIClient.shared.unlikeTimelineItem(with: timeline.id,
                                                   from: timeline.associatedEventId) { object, error, code in
                                                    if let error = error {
                                                        self.delegate?.showError(withText: error.localizedDescription)
                                                    } else {
                                                        timeline.liked = !timeline.liked
                                                        timeline.likeCount -= 1
                                                    }
                                                    self.populate(withTimeline: timeline)
            }
        } else {
            self.likesCountLabel.text = String(describing: timeline.likeCount + 1)
            
            SHOAPIClient.shared.likeTimelineItem(with: timeline.id,
                                                 from: timeline.associatedEventId) { object, error, code in
                                                    if let error = error {
                                                        self.delegate?.showError(withText: error.localizedDescription)
                                                    } else {
                                                        timeline.liked = !timeline.liked
                                                        timeline.likeCount += 1
                                                    }
                                                    self.populate(withTimeline: timeline)
            }
        }
    }
    
}
