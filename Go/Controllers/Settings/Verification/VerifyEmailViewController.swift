//
//  VerifyEmailViewController.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class VerifyEmailViewController: SHOTableViewController {
    
    private let existingEmail: String
    private var request = UserEmailRequestModel()
    
    private let mailSentCompletion: () -> Void
    
    lazy var sendEmailButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "EMAIL_VERIFICATION_SEND_MAIL".localized
        view.config = .action
        view.delegate = self
        return view
    }()
    
    init(email: String, mailSentCompletion: @escaping () -> Void) {
        self.existingEmail = email
        self.mailSentCompletion = mailSentCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "VERIFICATION_EMAIL".localized
    }
    
    override var style: UITableViewStyle {
        return .grouped
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.tableView.allowsSelection = false
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.sendEmailButtonView)
    }
    
    override func applyConstraints() {
        
        self.tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }
        
        self.sendEmailButtonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            
            self.tableView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            self.sendEmailButtonView.snp.makeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
            
            self.tableView.contentInset.bottom = Stylesheet.safeLayoutAreaBottomScrollInset
            
        } else {
            
            self.sendEmailButtonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(self.tableView.snp.bottom)
            }
            
        }
    }
}

// MARK: - ButtonViewDelegate

extension VerifyEmailViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        if let updatedEmail = self.request.email,
            updatedEmail != self.existingEmail {
            self.updateEmail()
        } else {
            self.sendVerification()
        }
    }
    
}

// MARK: - Networking

extension VerifyEmailViewController {
    
    private func updateEmail() {
        switch request.validate() {
        case .valid:
            self.showSpinner()
            SHOAPIClient.shared.updateMe(with: request) { (object, error, code) in
                self.dismissSpinner()
                
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                } else {
                    let alertMessage = "EMAIL_UPDATE_ALERT_MSG".localized + self.request.email!
                    let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                           message: alertMessage)
                    alert.addAction(UIViewController.okAction() { action in
                        self.mailSentCompletion()
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            }
        case .invalid(let errorString):
            self.showErrorAlertWith(message: errorString)
        }
    }
    
    private func sendVerification() {
        SHOAPIClient.shared.verifyEmail { (object, error, code) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.mailSentCompletion()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

// MARK: - UITableView Methods

extension VerifyEmailViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
        cell.topSeparatorView.isHidden = false
        cell.leftSeparatorMargin = 0
        cell.textField.placeholder = "EMAIL_PLACEHOLDER".localized
        cell.textField.text = self.existingEmail
        
        cell.textHandler = { [weak self] text in
            self?.request.email = text
        }
        
        return cell
    }
}
