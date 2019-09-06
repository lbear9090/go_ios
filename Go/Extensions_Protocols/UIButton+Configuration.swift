//
//  UIButton+Configuration.swift
//  Go
//
//  Created by Nouman Tariq on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

let AuthCornerRadius = CornerRadius.small.rawValue

extension ButtonConfig {

    // MARK: - Authorization
    
    static var landing: ButtonConfig {
        return ButtonConfig(textLabelColor: .white,
                            textLabelFont: Font.semibold.withSize(.large),
                            backgroundColor: .white,
                            cornerRadius: CornerRadius.medium.rawValue,
                            borderWidth: 0,
                            borderColor: .white)
    }
    
    static var auth: ButtonConfig {
        return ButtonConfig(textLabelColor: .white,
                            textLabelFont: Font.semibold.withSize(.large),
                            backgroundColor: .green,
                            cornerRadius: 24,
                            borderWidth: 0,
                            borderColor: .white)
    }
    
    // MARK: - Bordered Button
    
    static var bordered: ButtonConfig {
        return ButtonConfig(textLabelColor: .darkText,
                            textLabelFont: Font.regular.withSize(.medium),
                            borderWidth: 0.5,
                            borderColor: .black)
    }
    
    // MARK: - Action Button
    
    static var action: ButtonConfig {
        return ButtonConfig(textLabelColor: .white,
                            textLabelFont: Font.semibold.withSize(.medium),
                            backgroundColor: .green,
                            cornerRadius: CornerRadius.small.rawValue)
    }
    
    // MARK: - Destructive Button
    
    static var destructive: ButtonConfig {
        return ButtonConfig(textLabelColor: .white,
                            textLabelFont: Font.semibold.withSize(.medium),
                            backgroundColor: .red,
                            cornerRadius: CornerRadius.large.rawValue)
    }
}

public extension UIButton {
    
    public convenience init(with config: ButtonConfig) {
        self.init(type: .system)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setConfig(config)
    }
    
    public func setConfig(_ config: ButtonConfig) {
        self.layer.cornerRadius = config.cornerRadius
        self.backgroundColor = config.backgroundColor
        self.setTitleColor(config.textLabelColor, for: .normal)
        self.titleLabel?.font = config.textLabelFont
        self.layer.borderWidth = config.borderWidth
        self.layer.borderColor = config.borderColor.cgColor
    }
    
}

public struct ButtonConfig {
    let backgroundColor: UIColor
    let textLabelColor: UIColor
    let textLabelFont: UIFont
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor
    
    public init(textLabelColor: UIColor,
                textLabelFont: UIFont,
                backgroundColor: UIColor = .clear,
                cornerRadius: CGFloat = 0.0,
                borderWidth: CGFloat = 0.0,
                borderColor: UIColor = .clear) {
        self.backgroundColor = backgroundColor
        self.textLabelColor = textLabelColor
        self.textLabelFont = textLabelFont
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
}
