//
//  LandingViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

private let BottomSpacing: CGFloat = 60.0

class LandingViewController: BaseAuthViewController {
    
    private let logoImageView: UIImageView = {
        var imageView = UIImageView(image: .authLogo)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(with: .landing)
        button.backgroundColor = .logingButton
        button.setTitle("LANDING_LOGIN".localized, for: .normal)
        button.addTarget(self,
                         action: #selector(loginButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(with: .landing)
        button.backgroundColor = .signupButton
        button.setTitle("LANDING_REGISTER".localized, for: .normal)
        button.addTarget(self,
                         action: #selector(registerButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func setup() {
        super.setup()
        
        let text = ("LOGIN_FORGOT_PASSWORD".localized + "\n").attributedString(with: [.font: Font.regular.withSize(.small),
                                                                                      .foregroundColor: UIColor.white])
        
        text.append("LOGIN_FORGOT_PASSWORD_BOLD".localized.attributedString(with: [.font: Font.bold.withSize(.small),
                                                                                   .foregroundColor: UIColor.white]))
        self.forgotPasswordLabel.attributedText = text
        
        self.stackView.addArrangedSubview(self.logoImageView)
        self.stackView.addArrangedSubview(self.loginButton)
        self.stackView.addArrangedSubview(self.signUpButton)
        self.stackView.addArrangedSubview(self.forgotPasswordLabel)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.loginButton.snp.makeConstraints { make in
            make.height.equalTo(Stylesheet.buttonHeight)
            make.width.equalToSuperview()
        }
        
        self.signUpButton.snp.makeConstraints { make in
            make.height.equalTo(Stylesheet.buttonHeight)
            make.width.equalToSuperview()
        }
    }
    
    //MARK: - User Actions
    
    @objc private func loginButtonTapped() {
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }
    
    @objc private func registerButtonTapped() {
        self.navigationController?.pushViewController(RegisterAccountTypeViewController(), animated: true)
    }
    
    @objc private func helpLabelTapped() {
        self.navigationController?.pushViewController(ResetPasswordViewController(), animated: true)
    }
}
