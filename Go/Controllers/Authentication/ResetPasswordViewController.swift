//
//  ResetPasswordViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

class ResetPasswordViewController: BaseAuthViewController {
    
    private var email: String?
    
    private lazy var emailTextFieldView: AuthTextFieldView = {
        var view = AuthTextFieldView(withTFDelegate: self)
    
        view.placeholder = "RESET_PASSWORD_EMAIL".localized
        view.textField.keyboardType = .emailAddress
        view.textField.autocapitalizationType = .none
        view.textField.autocorrectionType = .no
        view.textField.addTarget(self,
                                 action: #selector(textFieldTextChanged),
                                 for: .editingChanged)
        return view
    }()
    
    private let resetPasswordButton: UIButton = {
        var button = AuthButton()
        button.setTitle("RESET_PASSWORD_BUTTON".localized, for: .normal)
        button.addTarget(self, action: #selector(resetPasswordTapped),
                         for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        
        self.titleLabel.text = "RESET_PASSWORD_TITLE".localized
        
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.emailTextFieldView)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.resetPasswordButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.emailTextFieldView.snp.makeConstraints(self.textFieldConstraintsClosure)
        self.resetPasswordButton.snp.makeConstraints(self.buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        self.email = sender.text
        self.resetPasswordButton.isEnabled = self.email?.isValidEmail() ?? false
    }
    
    @objc func resetPasswordTapped() {
        self.showSpinner()
        SHOAPIClient.shared.resetPassword(withEmail: self.email!) { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
                return
            }
            
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { [unowned self] action in
                self.navigationController?.popViewController(animated: true)
            })
            let successAlert = SHOViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                           message: "RESET_PASSWORD_SUCCESS_MSG".localized,
                                                           actions: [okAction])
            self.present(successAlert, animated: true, completion: nil)
        }
    }
}

//MARK: UITextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
