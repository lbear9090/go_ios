//
//  EventTableViewController.swift
//  Go
//
//  Created by Lucky on 12/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

private let IconSize = 16.0

class EventTableViewCell: SHOTableViewCell {
    
    let containerView: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.addShadow()
        view.backgroundColor = .white
        return view
    }()
    
    let eventImageView: UIImageView = {
        let imageView = UIImageView(image: .squareEventPlaceholder)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let privateEventImageView: UIImageView = UIImageView(image: .privateEventIcon)
    
    let attendeeCountLabel: CircularCountView = CircularCountView()
    
    let eventTitleLabel: UILabel = {
        let config = LabelConfig(textFont: Font.regular.withSize(.large),
                                 textColor: .text)
        let label = UILabel(with: config)
        return label
    }()
    
    let attendingImageView: UIImageView = {
        let imageView: UIImageView = UIImageView.newAutoLayout()
        imageView.isHidden = true
        
        return imageView
    }()
    
    let hostLabel: IconLabel = {
        let config = LabelConfig(textFont: Font.regular.withSize(.small),
                                 textColor: .text)
        let label = IconLabel(with: config)
        label.imageViewSize = CGSize(width: IconSize, height: IconSize)
        label.iconImageView.image = .eventHostIcon
        return label
    }()
    
    let locationLabel: IconLabel = {
        let config = LabelConfig(textFont: Font.regular.withSize(.small),
                                 textColor: .text)
        let label = IconLabel(with: config)
        label.imageViewSize = CGSize(width: IconSize, height: IconSize)
        label.iconImageView.image = .eventLocation
        return label
    }()
    
    let timeLabel: IconLabel = {
        let config = LabelConfig(textFont: Font.regular.withSize(.small),
                                 textColor: .text)
        let label = IconLabel(with: config)
        label.imageViewSize = CGSize(width: IconSize, height: IconSize)
        label.iconImageView.image = .eventTime
        return label
    }()
    
    let transparentView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .white
        view.layer.opacity = 0.6
        view.isHidden = true
        
        return view
    }()
    
    //MARK: - View Setup
    
    override func setup() {
        super.setup()
        self.separatorView.isHidden = true
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.containerView)
        
        self.containerView.addSubview(self.eventImageView)
        self.containerView.addSubview(self.attendeeCountLabel)
        self.containerView.addSubview(self.eventTitleLabel)
        self.containerView.addSubview(self.attendingImageView)
        self.containerView.addSubview(self.hostLabel)
        self.containerView.addSubview(self.locationLabel)
        self.containerView.addSubview(self.timeLabel)
        self.containerView.addSubview(self.transparentView)
        
        self.eventImageView.addSubview(self.privateEventImageView)
        self.privateEventImageView.isHidden = true
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.contentView.layoutMargins = UIEdgeInsetsMake(4.0, 0.0, 4.0, 0.0)
        
        self.containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.contentView.snp.topMargin)
            make.bottom.equalTo(self.contentView.snp.bottomMargin)
        }
        
        self.eventImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.eventImageView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 90.0, height: 90.0))
        }
        
        self.attendeeCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.attendeeCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.attendeeCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.eventImageView.snp.right).offset(8.0)
            make.height.equalTo(self.attendeeCountLabel.snp.width)
            make.centerY.equalTo(self.eventTitleLabel.snp.centerY)
        }
        
        self.eventTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.eventTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.attendeeCountLabel.snp.right).offset(5.0)
            make.top.equalTo(self.containerView.snp.topMargin)
            make.right.equalTo(self.attendingImageView.snp.left).offset(-5.0)
        }
        
        self.hostLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.eventTitleLabel.snp.bottom).offset(4.0)
            make.right.equalTo(self.attendingImageView.snp.left).offset(-5.0)
            make.left.equalTo(self.eventImageView.snp.right).offset(8.0)
        }
        
        self.attendingImageView.snp.makeConstraints { make in
            make.top.equalTo(self.containerView.snp.topMargin)
            make.right.equalTo(self.containerView.snp.rightMargin)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        self.locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.hostLabel.snp.bottom).offset(4.0)
            make.right.equalTo(self.containerView.snp.rightMargin)
            make.left.equalTo(self.eventImageView.snp.right).offset(8.0)
        }
        
        self.timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.locationLabel.snp.bottom).offset(4.0)
            make.right.equalTo(self.containerView.snp.rightMargin)
            make.left.equalTo(self.eventImageView.snp.right).offset(8.0)
            make.bottom.equalTo(self.containerView.snp.bottom).inset(4.0)
        }
        
        self.privateEventImageView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 56.0, height: 56.0))
        }
        
        self.transparentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.containerView.backgroundColor = highlighted ? .lightGray : .white
    }
    
    //MARK: - Configuration
    
    func configureCell(with event: EventModel) {
        self.eventTitleLabel.text = event.title
        self.attendeeCountLabel.count = event.attendeeCount
        self.hostLabel.text = event.host.displayName
        self.locationLabel.text = event.address

        let eventDate = Date(timeIntervalSince1970: event.date)
        let eventTime = Date(timeIntervalSince1970: event.time)
        
        if let dateString = eventDate.string(withFormat: .shorthand),
            let timeString = eventTime.string(withFormat: .time) {
            timeLabel.text = "\(timeString) • \(dateString.uppercased())"
        }
        
        if let imageUrlString = event.mediaItems.first?.images?.mediumUrl,
            let imageUrl = URL(string: imageUrlString) {
            self.eventImageView.kf.setImage(with: imageUrl, placeholder: UIImage.squareEventPlaceholder)
        } else {
            self.eventImageView.image = .squareEventPlaceholder
        }
        
        if event.userAttendance?.status == .going {
            self.attendingImageView.image = .attendingEvent
        } else {
            self.attendingImageView.image = .maybeAttendingEvent
        }
        
        self.privateEventImageView.isHidden = !event.isPrivate
        
        let eventTimeOfDaySeconds = eventTime.timeIntervalSince1970 - eventTime.startOfDay.timeIntervalSince1970
        let exactEventTimestamp = eventDate.startOfDay.timeIntervalSince1970 + eventTimeOfDaySeconds
        self.transparentView.isHidden = !Date(timeIntervalSince1970: exactEventTimestamp).isInPast
    }
}
