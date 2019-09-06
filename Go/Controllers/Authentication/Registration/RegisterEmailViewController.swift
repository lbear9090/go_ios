//
//  RegisterEmailViewController.swift
//  Go
//
//  Created by Lucky on 31/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class RegisterEmailViewController: BaseAuthViewController {
    
    var registrationRequest = RegistrationRequestModel()

    private lazy var emailTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "REGISTRATION_EMAIL".localized
        view.textField.autocorrectionType = .no
        view.textField.autocapitalizationType = .none
        view.textField.keyboardType = .emailAddress
        view.textField.text = registrationRequest.email
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
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
        
        self.titleLabel.text = "REGISTRATION_EMAIL_TITLE".localized
        
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.emailTextFieldView)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.nextButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.emailTextFieldView.snp.makeConstraints(self.textFieldConstraintsClosure)
        self.nextButton.snp.makeConstraints(self.buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    private func validateInput() {
        self.nextButton.isEnabled = self.registrationRequest.email?.isValidEmail() ?? false
    }
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        self.registrationRequest.email = sender.text
        self.validateInput()
    }
    
    @objc private func nextTapped() {
        self.checkEmailAvailable()
    }
    
    private func pushNextController() {
        let controller = RegisterPasswordViewController()
        controller.registrationRequest = self.registrationRequest
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Networking
    
    private func checkEmailAvailable() {
        guard let email = self.registrationRequest.email else {
            self.showErrorAlertWith(message: "REGISTRATION_NO_EMAIL".localized)
            return
        }
        
        self.showSpinner()
        SHOAPIClient.shared.checkAvailability(ofEmail: email) { (object, error, code) in
            self.dismissSpinner()
            
            if let availabilityModel = object as? AvailabilityModel {
                if availabilityModel.available {
                    self.pushNextController()
                } else {
                    self.showErrorAlertWith(message: "REGISTRATION_EMAIL_NOT_AVAILABLE".localized)
                }
            } else {
                self.pushNextController()
            }
        }
    }
    
}

//MARK: UITextFieldDelegate
extension RegisterEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
