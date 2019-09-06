//
//  RegisterNameViewController.swift
//  Go
//
//  Created by Lucky on 31/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class RegisterNameViewController: BaseAuthViewController {
    
    var registrationRequest = RegistrationRequestModel()

    private lazy var firstNameTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "REGISTRATION_FIRST_NAME".localized
        view.textField.autocorrectionType = .no
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        view.textField.text = registrationRequest.firstName
        return view
    }()
    
    private lazy var lastNameTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "REGISTRATION_LAST_NAME".localized
        view.textField.autocorrectionType = .no
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        view.textField.text = registrationRequest.lastName
        return view
    }()
    
    private let nextButton: UIButton = {
        var button = AuthButton()
        button.setTitle("REGISTRATION_CONTINUE".localized, for: .normal)
        button.addTarget(self, action: #selector(nextTapped),
                         for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.validateInput()
    }
    
    override func setup() {
        super.setup()
        self.titleLabel.text = "REGISTRATION_NAME_TITLE".localized
        
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.firstNameTextFieldView)
        self.stackView.addArrangedSubview(self.lastNameTextFieldView)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.nextButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.firstNameTextFieldView.snp.makeConstraints(textFieldConstraintsClosure)
        self.lastNameTextFieldView.snp.makeConstraints(textFieldConstraintsClosure)
        self.nextButton.snp.makeConstraints(buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    private func validateInput() {
        self.nextButton.isEnabled = !(self.registrationRequest.firstName?.isEmpty ?? true ||
                                        self.registrationRequest.lastName?.isEmpty ?? true)
    }
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        switch sender {
        case self.firstNameTextFieldView.textField:
            self.registrationRequest.firstName = sender.text
        case self.lastNameTextFieldView.textField:
            self.registrationRequest.lastName = sender.text
        default:
            break
        }
        self.validateInput()
    }
    
    @objc private func nextTapped() {
        let controller = RegisterEmailViewController()
        controller.registrationRequest = self.registrationRequest
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: UITextFieldDelegate

extension RegisterNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.firstNameTextFieldView.textField) {
            self.lastNameTextFieldView.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
