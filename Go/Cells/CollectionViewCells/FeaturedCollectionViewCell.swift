//
//  FeaturedCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let Spacing = CGFloat(8.0)

private let PrimaryColors = [#colorLiteral(red: 0.9215686275, green: 0.1098039216, blue: 0.3568627451, alpha: 1), #colorLiteral(red: 0.2039215686, green: 0.1490196078, blue: 0.7098039216, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.5764705882, blue: 0.1921568627, alpha: 1), #colorLiteral(red: 0.6470588235, green: 0.137254902, blue: 0.6823529412, alpha: 1), UIColor.green]
private let SecondaryColors = [#colorLiteral(red: 0.9568627451, green: 0.1568627451, blue: 0.1921568627, alpha: 1), #colorLiteral(red: 0.4470588235, green: 0.4274509804, blue: 0.8431372549, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.7294117647, blue: 0.1921568627, alpha: 1), #colorLiteral(red: 0.8392156863, green: 0.3019607843, blue: 0.9294117647, alpha: 1), UIColor.green]

class FeaturedCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = .eventPlaceholder
        return imageView
    }()
    
    let privateEventImageView: UIImageView = UIImageView(image: .privateEventIcon)
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.large)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let monthLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.extraSmall)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let stackViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()
    
    let eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.semibold.withSize(.medium)
        label.textColor = .white
        return label
    }()
    
    let eventOwnerLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.withSize(.medium)
        label.textColor = .white
        return label
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    private var stackGradientLayer: CAGradientLayer {
        let gradient = CAGradientLayer()
        let index = Int(arc4random_uniform(UInt32(PrimaryColors.count)))
        gradient.colors = [PrimaryColors[index].cgColor, SecondaryColors[index].cgColor]
        gradient.locations = [0.5, 1.0]
        gradient.opacity = 1.0
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5);
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: 38, height: 58)
        
        return gradient
    }
    
    //MARK: - View setup
    
    override func setup() {
        self.contentView.backgroundColor = .white
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.white.cgColor

        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.stackViewContainer)
        self.contentView.addSubview(self.eventNameLabel)
        self.contentView.addSubview(self.eventOwnerLabel)
        self.contentView.addSubview(self.privateEventImageView)
        
        self.stackViewContainer.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.dateLabel)
        self.stackView.addArrangedSubview(self.monthLabel)
        self.stackView.addArrangedSubview(self.timeLabel)
    }
    
    override func applyConstraints() {
        self.stackViewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(Spacing)
            make.size.equalTo(CGSize(width: 38, height: 58))
        }
        
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview()
        }
        
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.eventNameLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(Spacing)
        }
        
        self.eventOwnerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Spacing)
            make.bottom.equalTo(self.eventNameLabel.snp.top)
        }
        
        self.privateEventImageView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 56.0, height: 56.0))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.gradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.locations = [0.5, 1.0]
            gradient.opacity = 0.8
            gradient.frame = self.contentView.frame
            
            self.gradientLayer = gradient
            self.imageView.layer.addSublayer(gradient)
            
            self.stackViewContainer.layer.addSublayer(self.stackGradientLayer)
        }
        
        self.stackViewContainer.bringSubview(toFront: self.stackView)
    }
    
    //MARK - Configuration
    
    public func populate(with event: EventModel) {
        
        if let imageUrl = event.mediaItems.first?.images?.largeUrl {
            self.imageView.kf.setImage(with: URL(string: imageUrl),
                                       placeholder: UIImage.eventPlaceholder)
        }
        
        let date = Date(timeIntervalSince1970: event.date)
        let time = Date(timeIntervalSince1970: event.time)

        self.dateLabel.text = date.string(withFormat: DateFormat(value: "dd"))
        self.monthLabel.text = date.string(withFormat: DateFormat(value: "MMM"))
        self.timeLabel.text = time.string(withFormat: DateFormat(value: "HH:mm"))
        
        self.eventNameLabel.text = event.title
        self.eventOwnerLabel.text = event.host.displayName
        
        self.privateEventImageView.isHidden = !event.isPrivate
    }
}
