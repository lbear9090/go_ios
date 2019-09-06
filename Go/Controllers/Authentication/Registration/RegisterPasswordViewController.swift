//
//  RegisterPasswordViewController.swift
//  Go
//
//  Created by Lucky on 31/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class RegisterPasswordViewController: BaseAuthViewController {
    
    var registrationRequest = RegistrationRequestModel()

    private lazy var passwordTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "REGISTRATION_PASSWORD".localized
        view.textField.isSecureTextEntry = true
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        return view
    }()
    
    private let nextButton: UIButton = {
        var button = AuthButton()
        button.setTitle("REGISTRATION_PASSWORD_BUTTON".localized, for: .normal)
        button.addTarget(self, action: #selector(nextTapped),
                         for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        
        self.titleLabel.text = "REGISTRATION_PASSWORD_TITLE".localized
        
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.passwordTextFieldView)
        self.stackView.addArrangedSubview(self.termsLabel)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.nextButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.passwordTextFieldView.snp.makeConstraints(self.textFieldConstraintsClosure)
        self.nextButton.snp.makeConstraints(self.buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        self.registrationRequest.password = sender.text
        self.nextButton.isEnabled = (self.registrationRequest.password?.count ?? 0) >= Constants.minPasswordLength
    }
    
    @objc private func nextTapped() {
        let controller = RegisterInterestsViewController()
        controller.registrationRequest = self.registrationRequest
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: UITextFieldDelegate
extension RegisterPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
