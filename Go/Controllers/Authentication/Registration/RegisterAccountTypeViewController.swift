//
//  AccountTypeViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

enum AccountType: String, PickerValue {
    case personal = "personal"
    case group = "business"
    
    var pickerValue: String {
        switch self {
        case .personal:
            return "ACCOUNT_TYPE_PERSONAL".localized
        case .group:
            return "ACCOUNT_TYPE_GROUP".localized
        }
    }
}

class RegisterAccountTypeViewController: BaseAuthViewController {
    
    private let registrationRequest = RegistrationRequestModel()
    
    private var selectedAccountType: AccountType? {
        didSet {
            self.nextButton.isEnabled = selectedAccountType != nil
            self.registrationRequest.accountType = selectedAccountType?.rawValue
        }
    }
    
    private let accountTypes = [AccountType.personal,
                                AccountType.group]
    
    private lazy var pickerTextField: PickerViewTextField = {
        let textField = PickerViewTextField()
        
        let pickerSheet = PickerViewSheet(with: accountTypes, responder: textField)
        pickerSheet.toolbar.items = nil
        pickerSheet.selectionHandler = { [unowned self] object in
            if let accountType = object as? AccountType {
                textField.text = accountType.pickerValue
                self.selectedAccountType = accountType
            }
        }
        
        textField.inputView = pickerSheet
        return textField
    }()

    private lazy var accountTypeTextField: AuthTextFieldView = {
        let view = AuthTextFieldView(withTextField: self.pickerTextField)
        view.placeholder = "ACCOUNT_TYPE_PLACEHOLDER".localized
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
    
    override func setup() {
        super.setup()
        
        self.titleLabel.text = "ACCOUNT_TYPE_TITLE".localized

        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.accountTypeTextField)
        self.stackView.addArrangedSubview(UIView()) //Flexible space
        self.stackView.addArrangedSubview(self.nextButton)
        self.stackView.addArrangedSubview(self.bottomSpaceView)
        
        self.backgroundImageView.removeFromSuperview()
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.accountTypeTextField.snp.makeConstraints(self.textFieldConstraintsClosure)
        self.nextButton.snp.makeConstraints(self.buttonConstraintsClosure)
    }
    
    //MARK: - User actions
    
    @objc func nextTapped() {
        guard let accountType = self.selectedAccountType else {
            showErrorAlertWith(message: "ACCOUNT_TYPE_ERROR_NONE_SELECTED".localized)
            return
        }
        
        switch accountType {
        case .personal:
            self.registrationRequest.groupName = nil
            
            let controller = RegisterNameViewController()
            controller.registrationRequest = self.registrationRequest
            self.navigationController?.pushViewController(controller, animated: true)
            
        case .group:
            let controller = RegisterGroupNameViewController()
            controller.registrationRequest = self.registrationRequest
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
