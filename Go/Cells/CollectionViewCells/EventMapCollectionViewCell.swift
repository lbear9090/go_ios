//
//  MapViewController.swift
//  Go
//
//  Created by Lucky on 17/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

private let SelectedBorderHeight: CGFloat = 1.0

protocol MapEventCollectionViewCellDelegate {
    func didSelectUser(_ user: UserModel)
    func didTapOptions(for event: EventModel)
}

class EventMapCollectionViewCell: BaseCollectionViewCell, ItemOwnerCollectionViewCellDelegate {
    
    //MARK: - Properties
    
    var delegate: MapEventCollectionViewCellDelegate?
    private var event: EventModel?
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    lazy var ownerView: ItemOwnerCollectionViewCell = {
        let view = ItemOwnerCollectionViewCell(frame: self.frame)
        view.delegate = self
        view.topSeparatorView.isHidden = true
        let ownerTGR = UITapGestureRecognizer(target: self,
                                              action: #selector(didTapOwnerView))
        view.addGestureRecognizer(ownerTGR)
        return view
    }()
    
    let imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let eventNameLabel: UILabel = {
        var label = UILabel()
        label.textColor = .darkText
        label.font = Font.semibold.withSize(.medium)
        label.numberOfLines = 1
        return label
    }()
    
    let eventTimeLabel: UILabel = {
        var label = IconLabel(icon: .eventTime)
        label.textColor = .darkText
        label.font = Font.regular.withSize(.small)
        label.numberOfLines = 1
        return label
    }()
    
    let selectedView: UIView = {
        var view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    let countView: CircularCountView = CircularCountView()
    
    let detailsStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    let labelsStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    override var isSelected: Bool {
        didSet {
            self.selectedView.alpha = super.isSelected ? 1 : 0
        }
    }
    
    //MARK: - View setup
    
    override func setup() {
        self.contentView.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.selectedView)
        self.stackView.addArrangedSubview(self.ownerView)
        self.stackView.addArrangedSubview(self.imageView)
        self.stackView.addArrangedSubview(self.detailsStackView)
        
        
        self.labelsStackView.addArrangedSubview(self.eventNameLabel)
        self.labelsStackView.addArrangedSubview(self.eventTimeLabel)
        
        self.detailsStackView.addArrangedSubview(self.labelsStackView)
        self.detailsStackView.addArrangedSubview(self.countView)
    }
    
    override func applyConstraints() {
        self.layoutMargins = UIEdgeInsetsMake(0, 5, 10, 5)
        
        self.selectedView.snp.makeConstraints { make in
            make.height.equalTo(SelectedBorderHeight)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.leftMargin)
            make.right.equalTo(self.snp.rightMargin)
            make.bottom.equalTo(self.snp.bottomMargin)
            make.top.equalTo(self.snp.topMargin)
        }
        
        self.ownerView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        [self.eventNameLabel, self.eventTimeLabel].forEach {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        
        self.countView.setContentHuggingPriority(.required, for: .horizontal)
        self.countView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.countView.snp.makeConstraints { (make) in
            make.height.equalTo(self.countView.snp.width)
        }
    }
    
    //MARK: - Configuration
    
    func configureCell(with event: EventModel) {
        self.event = event
        
        self.eventNameLabel.text = event.title
        
        if let dateString =  Date(timeIntervalSince1970: event.date).string(withFormat: .shorthand),
            let timeString = Date(timeIntervalSince1970: event.time).string(withFormat: .time) {
            self.eventTimeLabel.text = "\(timeString) • \(dateString.uppercased())"
        }
        
        if let imageUrl = event.mediaItems.first?.images?.mediumUrl {
            self.imageView.kf.setImage(with: URL(string: imageUrl),
                                       placeholder: UIImage.squareEventPlaceholder)
        }
        
        self.ownerView.populate(with: event.host)
        
        self.countView.count = event.attendeeCount
    }
    
    //MARK: - User interaction
    
    @objc private func didTapOwnerView() {
        if let user = self.event?.host {
            self.delegate?.didSelectUser(user)
        }
    }
    
    func didSelectOptionsButton() {
        if let event = self.event {
            self.delegate?.didTapOptions(for: event)
        }
    }
    
}



