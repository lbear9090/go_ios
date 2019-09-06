//
//  MessageCollectionView+Status.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import MessageKit
import SnapKit

protocol DeliveredStatusViewProtocol {
    var rightStatusImageView: UIImageView { get set }
    var leftStatusImageView: UIImageView { get set }
    
    func setupDeliveredStatusView()
    
    func configure(with message: MessageType,
                   currentSender: Bool,
                   seen: Bool,
                   at indexPath: IndexPath,
                   and messagesCollectionView: MessagesCollectionView)
}

// MARK: - MessageCollectionViewCell Extension -

extension MessageCollectionViewCell: DeliveredStatusViewProtocol {
    
    // Workaround to get around Swifts inability to deal with stored properties in extensions
    private struct DeliveredStatusProperties {
        static var rightStatusImageView: UIImageView = UIImageView()
        static var leftStatusImageView: UIImageView = UIImageView()
    }
    
    var rightStatusImageView: UIImageView {
        get {
            return DeliveredStatusProperties.rightStatusImageView
        }
        set {
            DeliveredStatusProperties.rightStatusImageView = newValue
        }
    }
    
    var leftStatusImageView: UIImageView {
        get {
            return DeliveredStatusProperties.leftStatusImageView
        }
        set {
            DeliveredStatusProperties.leftStatusImageView = newValue
        }
    }
    
    func setupDeliveredStatusView() {
        self.rightStatusImageView = self.statusView()
        self.leftStatusImageView = self.statusView()
        
        self.contentView.addSubview(self.rightStatusImageView)
        self.contentView.addSubview(self.leftStatusImageView)
        
        self.rightStatusImageView.snp.makeConstraints { make in
            make.top.equalTo(self.messageContainerView.snp.bottom)
            make.right.equalTo(self.messageContainerView.snp.right).inset(5)
        }
        
        self.leftStatusImageView.snp.makeConstraints { make in
            make.top.equalTo(self.messageContainerView.snp.bottom)
            make.left.equalTo(self.messageContainerView.snp.left).inset(5)
        }
    }
    
    func configure(with message: MessageType, currentSender: Bool, seen: Bool, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        self.leftStatusImageView.isHidden  = true //currentSender ? true : false
        self.rightStatusImageView.isHidden = true //currentSender ? false : true
        self.leftStatusImageView.image = nil //seen ? UIImage(named: "seen") : UIImage(named: "delivered")
        self.rightStatusImageView.image = nil //seen ? UIImage(named: "seen") : UIImage(named: "delivered")
    }
    
    // MARK: Helpers
    
    private func statusView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }
    
}

// MARK: - Subclasses -

class TextDeliveredMessageCell: TextMessageCell {
    
    override func setupSubviews() {
        super.setupSubviews()
        self.setupDeliveredStatusView()
    }
    
}

class MediaDeliveredMessageCell: MediaMessageCell {
    
    override func setupSubviews() {
        super.setupSubviews()
        self.setupDeliveredStatusView()
    }
    
}

class LocationDeliveredMessageCell: LocationMessageCell {
    
    override func setupSubviews() {
        super.setupSubviews()
        self.setupDeliveredStatusView()
    }
    
}
