//
//  ChangePasswordViewController.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum ChangePasswordRow: Int {
    case current
    case newPassword
    case confirmPassword
    case ROW_COUNT
    
    var placeholder: String {
        switch self {
        case .current:
            return "CHANGE_PASSWORD_CURRENT_PASSWORD_PH".localized
        case .newPassword:
            return "CHANGE_PASSWORD_NEW_PASSWORD_PH".localized
        case .confirmPassword:
            return "CHANGE_PASSWORD_CONFIRM_PASSWORD_PH".localized
        default:
            return "".localized
        }
    }
}

class ChangePasswordViewController: SHOTableViewController {
    
    //Properties
    private var currentPassword: String?
    private var passwordConfirmation: String?
    private var newPassword: String?

    // MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CHANGE_PASSWORD_TITLE".localized
        
        let button = UIBarButtonItem(image: .saveIcon,
                                     style: .plain,
                                     target: self,
                                     action: #selector(saveButtonPressed))
        self.navigationItem.rightBarButtonItem = button
    }
    
    // MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChangePasswordRow.ROW_COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
        cell.separatorView.isHidden = true
        cell.textField.isSecureTextEntry = true
        cell.textField.textColor = .text
        
        if let row = ChangePasswordRow(rawValue: indexPath.row) {
            cell.textField.placeholder = row.placeholder
            
            cell.textHandler = { [weak self] text in
                switch row {
                case .current:
                    self?.currentPassword = text
                case .newPassword:
                    self?.passwordConfirmation = text
                case .confirmPassword:
                    self?.newPassword = text
                default:
                    break
                }
            }
        }
        
        return cell
    }
    
    // MARK: - User Actions
    
    @objc func saveButtonPressed() {
        guard
            let current = self.currentPassword, !current.isEmpty,
            let new = self.newPassword, !new.isEmpty,
            let confirm = self.passwordConfirmation, !confirm.isEmpty else {
                
                self.showErrorAlertWith(message: "CHANGE_PASSWORD_FILL_FIELDS".localized)
                return
        }
        
        guard new.count >= Constants.minPasswordLength else {
            self.showErrorAlertWith(message: "CHANGE_PASSWORD_MIN_LENGTH".localized)
            return
        }
        
        guard new == confirm else {
            self.showErrorAlertWith(message: "CHANGE_PASSWORD_MISMATCH".localized)
            return
        }
        
        self.showSpinner()
        SHOAPIClient.shared.updatePassword(from: current, to: new) { (object, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                
                let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { [unowned self] action in
                    self.navigationController?.popViewController(animated: true)
                })
                let successAlert = SHOViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                               message: "CHANGE_PASSWORD_SUCCESS_MSG".localized,
                                                               actions: [okAction])
                self.present(successAlert, animated: true, completion: nil)
            }
        }
    }
}
