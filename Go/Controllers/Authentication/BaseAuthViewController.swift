//
//  BaseAuthViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

private let StackViewSpacing: CGFloat = 10.0
private let BottomSpacing: CGFloat = 30.0

class BaseAuthViewController: SHOViewController {
    
    //MARK: - Properties
    
    var keyboardNotificationObservers: [NSObjectProtocol] = []

    let titleLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        label.textAlignment = .center
        label.font = Font.medium.withSize(.extraLarge)
        label.textColor = .darkText
        return label
    }()
    
    let backgroundImageView: UIImageView = {
        var imageView = UIImageView(image: .landingBackground)
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var termsLabel: UILabel = {
        var label: UILabel = UILabel.newAutoLayout()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let text = ("REGISTRATION_T&C".localized + "\n").attributedString(with: [.font: Font.regular.withSize(.small),
                                                                                 .foregroundColor: UIColor.darkText])
        
        text.append("REGISTRATION_T&C_BOLD".localized.attributedString(with: [.font: Font.bold.withSize(.small),
                                                                              .foregroundColor: UIColor.green]))
        label.attributedText = text
        
        let touchGesture = UITapGestureRecognizer(target: self,
                                                  action: #selector(termsLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(touchGesture)
        
        return label
    }()
    
    lazy var forgotPasswordLabel: UILabel = {
        var label: UILabel = UILabel.newAutoLayout()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let text = ("LOGIN_FORGOT_PASSWORD".localized + "\n").attributedString(with: [.font: Font.regular.withSize(.small),
                                                                                      .foregroundColor: UIColor.darkText])

        text.append("LOGIN_FORGOT_PASSWORD_BOLD".localized.attributedString(with: [.font: Font.bold.withSize(.small),
                                                                                   .foregroundColor: UIColor.green]))
        label.attributedText = text
        
        let touchGesture = UITapGestureRecognizer(target: self,
                                                  action: #selector(forgotPasswordLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(touchGesture)
        
        return label
    }()
    
    let bottomSpaceView = UIView()
    
    lazy var stackView: UIStackView = {
        var stackView: UIStackView = UIStackView.newAutoLayout()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = StackViewSpacing
        return stackView
    }()
    
    private var stackViewBottomConstraint: Constraint?
    
    //MARK: - Lifecycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureAuthenticationNavBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterForKeyboardNotifications()
    }
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        self.view.insertSubview(self.backgroundImageView, at: 0)        
        self.view.addSubview(self.stackView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        if self.backgroundImageView.superview != nil {
            self.backgroundImageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view.snp.leftMargin)
            make.right.equalTo(self.view.snp.rightMargin)
            self.stackViewBottomConstraint = make.bottom.equalToSuperview().constraint
        }
        
        self.bottomSpaceView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(BottomSpacing)
        }
        
        self.termsLabel.setContentHuggingPriority(.required, for: .vertical)
        self.termsLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.forgotPasswordLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.forgotPasswordLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    //MARK: - User interaction
    
    @objc func termsLabelTapped() {
        if let configurations = try? CacheManager.getConfigurations(),
            let termsUrl = configurations.termsUrl {
            SHOWebViewController.presentModally(withUrlString: termsUrl,
                                                fromController: self,
                                                withTitle: "SETTINGS_TERMS_CONDITIONS".localized)
        } else {
            self.showErrorAlertWith(message: "ERROR_NO_TERMS_URL".localized)
        }
    }
    
    @objc private func forgotPasswordLabelTapped() {
        self.navigationController?.pushViewController(ResetPasswordViewController(), animated: true)
    }
    
    //MARK: - Helpers
    
    func buttonConstraintsClosure(_ make: ConstraintMaker) {
        make.height.equalTo(Stylesheet.authButtonHeight)
        make.width.equalToSuperview().multipliedBy(0.6)
    }
    
    func textFieldConstraintsClosure(_ make: ConstraintMaker) {
        make.height.equalTo(AuthTextFieldView.Height)
        make.width.equalToSuperview()
    }

}

// MARK: - Keyboard notifications

extension BaseAuthViewController: SHOKeyboardNotifications {
    
    func animateLayoutForKeyboard(frame: CGRect) {
        self.stackViewBottomConstraint?.update(inset: frame.height)
        self.view.layoutIfNeeded()
    }
    
}
