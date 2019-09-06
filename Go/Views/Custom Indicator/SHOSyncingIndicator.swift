//
//  SHOSyncingIndicator.swift
//  Go
//
//  Created by George Chalkiadoudis on 17/08/2018.
//  Copyright © 2018 Go. All rights reserved.
//
//  Custom UIView with an indicator and a "Syncing..." label

import UIKit

class SHOSyncingIndicator: SHOView {
    
    private let containerView = UIView.newAutoLayout()
    private var label: UILabel!
    private var indicator: UIActivityIndicatorView!
    
    private var labelConfig: LabelConfig = LabelConfig(textFont: Font.regular.withSize(.extraSmall), textColor: .black)
    
    override func setup() {
        self.backgroundColor = .notificationUnreadBackground
        
        label = UILabel(with: labelConfig)
        label.translatesAutoresizingMaskIntoConstraints = true
        label.textAlignment = .center
        label.text = "Syncing..."
        
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .green
        
        self.containerView.addSubview(label)
        self.containerView.addSubview(indicator)
        
        self.addSubview(self.containerView)
    }
    
    func startIndicatorAnimation() {
        self.indicator.startAnimating()
    }
    
    func stopIndicatorAnimation() {
        self.indicator.stopAnimating()
    }
    
    override func applyConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        self.indicator.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.right.equalTo(label.snp.left).offset(-4)
        }
        
        self.label.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
        }
    }
}
