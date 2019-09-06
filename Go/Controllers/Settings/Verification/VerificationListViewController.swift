//
//  VerificationListViewController.swift
//  Go
//
//  Created by Lucky on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

enum VerificationListRows: Int {
    case userDetails
    case email
    case identity
    case payoutMethod
    case businessDetails
    case ROW_COUNT
    
    var title: String {
        switch self {
        case .userDetails:
            return "VERIFICATION_USER_DETAILS".localized
        case .email:
            return "VERIFICATION_EMAIL".localized
        case .identity:
            return "VERIFICATION_ID".localized
        case .payoutMethod:
            return "VERIFICATION_PAYOUT".localized
        case .businessDetails:
            return "VERIFICATION_BUSINESS".localized
        default:
            return ""
        }
    }
    
    func required(in verifications: VerificationsModel) -> Bool {
        switch self {
        case .userDetails:
            return verifications.detailsVerificationRequired
        case .email:
            return verifications.email
        case .identity:
            return verifications.identification
        case .payoutMethod:
            return verifications.bankAccount
        case .businessDetails:
            return verifications.businessDetails
        default:
            return true
        }
    }
}

typealias VerificationHandler = ((UserModel) -> Void)

class VerificationListViewController: SHOTableViewController {
    
    private var hasInitialUser = false
    private var emailVerificationPending: Bool = false
    private var loadingMessage: String?
    
    lazy var stripeManager: StripeCardManager = StripeCardManager(withController: self)
    
    private var currentUser: UserModel? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var verifiedHandler: VerificationHandler?
    
    convenience init(with user: UserModel, verifiedHandler handler: @escaping VerificationHandler) {
        self.init()
        self.currentUser = user
        self.verifiedHandler = handler
        self.hasInitialUser = true
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CacheManager.getCurrentUser { user, error in
            if let user = user {
                self.currentUser = user
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "SETTINGS_VERIFICATION".localized
        if !self.hasInitialUser {
            self.fetchUser()
        }
        self.hasInitialUser = false
    }
    
    //MARK: - Networking
    
    func fetchUser() {
        self.showSpinner(withTitle: self.loadingMessage)
        SHOAPIClient.shared.getMe { (object, error, code) in
            
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            if let user = object as? UserModel {
                self.currentUser = user
                
                if self.shouldRetry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.fetchUser()
                    })
                } else {
                    self.emailVerificationPending = false
                    self.loadingMessage = nil
                    self.dismissSpinner()
                }
                
                self.checkVerifiedState(of: user)
            }
        }
    }
    
    var shouldRetry: Bool {
        let emailRequired = self.currentUser?.requiredVerifications?.email ?? false
        return self.emailVerificationPending && emailRequired
    }

    //MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = VerificationListRows.ROW_COUNT.rawValue
        if self.currentUser?.accountType != Constants.businessAccountType {
            //Don't show business details row if not business account
            rowCount -= 1
        }
        return rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView)
        cell.separatorView.isHidden = true
        cell.tintColor = .green
        
        if let rowInfo = VerificationListRows(rawValue: indexPath.row) {
            cell.textLabel?.text = rowInfo.title
            
            var infoRequired: Bool = true
            if
                let user = currentUser,
                let verifications = user.requiredVerifications {
                infoRequired = rowInfo.required(in: verifications)
            }
            cell.accessoryType = infoRequired ? .none : .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard  let user = currentUser else {
            return
        }
        
        if let row = VerificationListRows(rawValue: indexPath.row) {
            switch row {
            case .userDetails:
                let controller = VerifyUserDetailsViewController(user: user)
                self.navigationController?.pushViewController(controller, animated: true)
                
            case .email:
                guard let email = user.email else {
                    return
                }
                let controller = VerifyEmailViewController(email: email) { [unowned self] in
                    self.emailVerificationPending = true
                    self.loadingMessage = "VERIFY_EMAIL_LOADING".localized
                }
                self.navigationController?.pushViewController(controller , animated: true)
                
            case .payoutMethod:
                let controller = AddBankAccountViewController()
                self.navigationController?.pushViewController(controller, animated: true)
                
            case .identity:
                let controller = VerifyIdentityViewController(user: user)
                self.navigationController?.pushViewController(controller, animated: true)
                
            case .businessDetails:
                let controller = VerifyBusinessDetailsViewController(businessDetails: user.businessDetails)
                self.navigationController?.pushViewController(controller, animated: true)
                break
                
            default:
                break
            }
        }
    }
    
    //MARK: - Helpers
    
    func checkVerifiedState(of user: UserModel) {
        
        if let handler = self.verifiedHandler,
            let verifications = user.requiredVerifications,
            verifications.allFulfilled {
            handler(user)
        }
    }
    
    static func verifyUser(from controller: SHOViewController, withVerifiedHandler handler: @escaping VerificationHandler) {
        controller.showSpinner()
        SHOAPIClient.shared.getMe { (object, error, code) in
            controller.dismissSpinner()

            if let error = error {
                controller.showErrorAlertWith(message: error.localizedDescription)
            }
            if let user = object as? UserModel {
                if user.requiredVerifications?.allFulfilled ?? false {
                    handler(user)
                } else {
                    
                    let okAction = UIViewController.okAction { [unowned controller] action in
                        let verificationController = VerificationListViewController(with: user, verifiedHandler: handler)
                        let navController = UINavigationController(rootViewController: verificationController)
                        controller.present(navController,
                                           animated: true,
                                           completion: nil)
                    }
                    
                    let cancelAction = UIViewController.cancelAction()
                    let alert = UIViewController.alertWith(title: "VERIFICATION_REQUIRED_ALERT_TITLE".localized,
                                                           message: "VERIFICATION_REQUIRED_ALERT_MSG".localized,
                                                           actions: [okAction, cancelAction])
                    controller.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}
