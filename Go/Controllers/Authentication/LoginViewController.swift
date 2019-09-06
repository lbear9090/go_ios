//
//  LoginViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: BaseAuthViewController {
    
    private var email: String?
    private var password: String?
        
    private lazy var emailTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "LOGIN_EMAIL".localized
        view.textField.autocapitalizationType = .none
        view.textField.autocorrectionType = .no
        view.textField.keyboardType = .emailAddress
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        return view
    }()
    
    private lazy var passwordTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "LOGIN_PASSWORD".localized
        view.textField.isSecureTextEntry = true
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        return view
    }()
    
    private let loginButton: UIButton = {
        var button = AuthButton()
        button.setTitle("LOGIN_BUTTON".localized, for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
        
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        
        self.titleLabel.text = "LOGIN_TITLE".localized
            
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.emailTextFieldView)
        self.stackView.addArrangedSubview(self.passwordTextFieldView)
        self.stackView.addArrangedSubview(self.forgotPasswordLabel)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.loginButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.emailTextFieldView.snp.makeConstraints(textFieldConstraintsClosure)
        self.passwordTextFieldView.snp.makeConstraints(textFieldConstraintsClosure)
        self.loginButton.snp.makeConstraints(buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        switch sender {
        case self.emailTextFieldView.textField:
            self.email = sender.text
        case self.passwordTextFieldView.textField:
            self.password = sender.text
        default:
            break
        }
        self.loginButton.isEnabled = (self.password?.count ?? 0 >= Constants.minPasswordLength) &&
            (self.email?.isValidEmail() ?? false)
    }
    
    @objc private func loginTapped() {
        
        let request = LoginRequestModel(email: self.email!, password: self.password!)
        
        self.showSpinner()
        SHOAPIClient.shared.login(with: request) { (object, error, code) in
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if object is AuthTokenModel {
                self.getCurrentUser()
            }
        }
    }
    
    //MARK: - Networking
    
    private func getCurrentUser() {
        SHOAPIClient.shared.getMe { object, error, code in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.rootToFeedController()
            }
        }
    }
    
}

//MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.isEqual(self.emailTextFieldView.textField)) {
            self.passwordTextFieldView.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
