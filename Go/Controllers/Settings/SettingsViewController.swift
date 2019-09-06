//
//  SettingsViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum SectionType: Int {
    case findFriends
    case importEvents
    case myDetails
    case stripeDetails
    case settings
    case support
    
    var title: String? {
        switch self {
        case .findFriends:
            return "SETTINGS_FIND_FRIENDS".localized
        case .importEvents:
            return "SETTINGS_IMPORT_EVENTS".localized
        case .myDetails:
            return "SETTINGS_MY_DETAILS".localized
        case .stripeDetails:
            return "SETTINGS_STRIPE_DETAILS".localized
        case .settings:
            return "SETTINGS_SETTINGS".localized
        case .support:
            return "SETTINGS_ADDITIONAL".localized
        }
    }
}

private enum Item {
    
    case findFBFriends
    case importFBEvents
    case editProfile
    case changePassword
    case paymentMethod
    case payoutMethod
    case verification
    case notifications
    case help
    case termsAndConditions
    case logout
    case version
    
    var title: String {
        switch self {
        case .findFBFriends:
            return "SETTINGS_FIND_FRIENDS".localized
        case .importFBEvents:
            return "SETTINGS_IMPORT_FB_EVENTS".localized
        case .editProfile:
            return "SETTINGS_EDIT_PROFILE".localized
        case .changePassword:
            return "SETTINGS_CHANGE_PASSWORD".localized
        case .paymentMethod:
            return "SETTINGS_PAYMENT_METHOD".localized
        case .payoutMethod:
            return "SETTINGS_PAYOUT_METHOD".localized
        case .verification:
            return "SETTINGS_VERIFICATION".localized
        case .notifications:
            return "SETTINGS_NOTIFICATIONS".localized
        case .help:
            return "SETTINGS_HELP".localized
        case .termsAndConditions:
            return "SETTINGS_TERMS_CONDITIONS".localized
        case .logout:
            return "SETTINGS_LOG_OUT".localized
        case .version:
            return SHOUtils.versionBuildString ?? ""
        }
    }
}

private struct Section {
    var type: SectionType
    var items: [Item]
}

class SettingsViewController: SHOTableViewController {
    
    override var style: UITableViewStyle {
        return .grouped
    }
    
    private let sections: [Section] = [
            Section(type: .findFriends, items: [.findFBFriends]),
            Section(type: .importEvents, items: [.importFBEvents]),
            Section(type: .myDetails, items: [.editProfile, .changePassword]),
            Section(type: .stripeDetails, items: [.paymentMethod, .payoutMethod, .verification]),
            Section(type: .settings, items: [.notifications]),
            Section(type: .support, items: [.help, .termsAndConditions, .logout, .version])
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "SETTINGS_TITLE".localized
        self.configureNavigationBarForUseInTabBar()
    }
    
}

// MARK: - UITableViewDataSource

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        
        if section.type == .importEvents {
            return 0
        }
        return section.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .version:
            let cell = VersionTableViewCell(reuseIdentifier: VersionTableViewCell.reuseIdentifier)
            cell.titleLabel.textAlignment = .center
            cell.titleLabel.text = SHOUtils.versionBuildString ?? ""
            return cell
            
        default:
            let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
                cell.accessoryType = .disclosureIndicator
            }
            cell.textLabel?.text = row.title
            cell.textLabel?.textColor = (row == .logout) ? .red : .darkText

            if indexPath.section == SectionType.findFriends.rawValue {
                cell.imageView?.image = .eventFriends
            } else if indexPath.section == SectionType.importEvents.rawValue {
                cell.imageView?.image = .settingsFBLogo
            } else {
                cell.imageView?.image = nil
            }
            
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = self.sections[section]
        
        if section.type == .importEvents {
            return .leastNonzeroMagnitude
        }
        return Stylesheet.textSectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Stylesheet.textSectionHeaderHeight)
        let headerView = SectionHeaderView(frame: frame)
        
        headerView.leftLabel.font = Font.medium.withSize(.medium)
        headerView.leftLabel.textColor = .green
        headerView.leftLabel.text = SectionType(rawValue: section)?.title?.uppercased()
        
        // TODO : remove this when import FB events is back
        let section = self.sections[section]
        if section.type == .importEvents {
            headerView.leftLabel.text = ""
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        switch sections[indexPath.section].items[indexPath.row] {
        case .findFBFriends:
            let controller = SearchSegmentedControlViewController.findFriendsConfiguration()
            controller.addNavBarLogo = false
            controller.title = "SETTINGS_FIND_FRIENDS".localized
            self.navigationController?.pushViewController(controller, animated: true)

        case .importFBEvents:
            self.requestEventsPermission()
            
        case .editProfile:
            self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
            
        case .changePassword:
            self.navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
            
        case .paymentMethod:
            self.navigationController?.pushViewController(PaymentMethodsViewController(), animated: true)
            
        case .payoutMethod:
            self.navigationController?.pushViewController(PayoutMethodsViewController(), animated: true)
            
        case .verification:
            self.navigationController?.pushViewController(VerificationListViewController(), animated: true)
            
        case .notifications:
            self.navigationController?.pushViewController(NotificationSettingsViewController(), animated: true)
            
        case .termsAndConditions:
            self.presentTermsWebView()
            
        case .help:
            self.presentSupportWebView()
            
        case .logout:
            self.presentLogoutConfirmation()
            
        default:
            break
        }
    }
    
    // MARK: Helpers
    
    private func requestEventsPermission() {
        FBPermissionsManager.requestUserPermission(.userEvents, onController: self) { error in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.importFBEvents()
            }
        }
    }
    
    private func importFBEvents() {
        self.showSpinner()
        SHOAPIClient.shared.importFBEvents { object, error, code in
            DispatchQueue.main.async {
                self.dismissSpinner()
            }
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            
            } else if let importResult = object as? FBEventImportModel {
                let okAction = SHOViewController.okAction { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                let alert = SHOViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                        message: importResult.message,
                                                        actions: [okAction])
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
            }
        }
    }
    
    private func presentTermsWebView() {
        if let configurations = try? CacheManager.getConfigurations(),
            let termsUrl = configurations.termsUrl {
            SHOWebViewController.presentModally(withUrlString: termsUrl,
                                                fromController: self,
                                                withTitle: "SETTINGS_TERMS_CONDITIONS".localized)
        } else {
            self.showErrorAlertWith(message: "ERROR_NO_TERMS_URL".localized)
        }
    }
    
    private func presentSupportWebView() {
        if let configurations = try? CacheManager.getConfigurations(),
            let helpUrl = configurations.supportUrl {
            SHOWebViewController.presentModally(withUrlString: helpUrl,
                                                fromController: self,
                                                withTitle: "SETTINGS_HELP".localized)
        } else {
            self.showErrorAlertWith(message: "ERROR_NO_SUPPORT_URL".localized)
        }
    }

    private func presentLogoutConfirmation() {
        let yesAction = UIViewController.yesAction { (action) in
            self.logoutUser()
        }
        let noAction = UIViewController.noAction()
        
        let alert = UIViewController.alertWith(title: "LOGOUT_CONFIRMATION_TITLE".localized,
                                               message: "LOGOUT_CONFIRMATION_MSG".localized,
                                               actions: [yesAction, noAction])
        self.present(alert, animated: true)
    }
    
    private func logoutUser() {
        self.showSpinner()
        
        SHOAPIClient.shared.logout { object, error, code in
            self.dismissSpinner()
            SHOUtils.logoutUser()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.rootToLandingController()
        }
    }
    
}

