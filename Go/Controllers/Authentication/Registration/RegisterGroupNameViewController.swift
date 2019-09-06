//
//  RegisterGroupNameViewController.swift
//  Go
//
//  Created by Lucky on 31/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class RegisterGroupNameViewController: BaseAuthViewController {
    
    var registrationRequest = RegistrationRequestModel()

    private lazy var groupNameTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
        view.placeholder = "REGISTRATION_GROUP_NAME_PLACEHOLDER".localized
        view.textField.autocorrectionType = .no
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        view.textField.text = registrationRequest.groupName
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
        self.titleLabel.text = "REGISTRATION_GROUP_NAME_TITLE".localized

        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.groupNameTextFieldView)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.nextButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.groupNameTextFieldView.snp.makeConstraints(textFieldConstraintsClosure)
        self.nextButton.snp.makeConstraints(buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    private func validateInput() {
        self.nextButton.isEnabled = (self.registrationRequest.groupName?.count ?? 0) > 2
    }
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        self.registrationRequest.groupName = sender.text
        self.validateInput()
    }
    
    @objc private func nextTapped() {
        self.checkNameAvailability()
    }
    
    private func pushNextController() {
        let controller = RegisterNameViewController()
        controller.registrationRequest = self.registrationRequest
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Networking
    
    private func checkNameAvailability() {
        guard let name = self.registrationRequest.groupName else {
            self.showErrorAlertWith(message: "REGISTRATION_NO_GROUP_NAME".localized)
            return
        }
        
        self.showSpinner()
        SHOAPIClient.shared.checkAvailability(ofGroupName: name) { (object, error, code) in
            self.dismissSpinner()
            
            if let availabilityModel = object as? AvailabilityModel {
                if availabilityModel.available {
                    self.pushNextController()
                } else {
                    self.showErrorAlertWith(message: "REGISTRATION_GROUP_NAME_NOT_AVAILABLE".localized)
                }
            } else if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
        }
    }

}

//MARK: UITextFieldDelegate

extension RegisterGroupNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
