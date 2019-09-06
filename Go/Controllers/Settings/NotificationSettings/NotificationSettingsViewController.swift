//
//  NotificationSettingsViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: SHOTableViewController {
    
    private var user: UserModel? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - View setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "NOTIFICATIONS_TITLE".localized
        self.fetchUser()
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.allowsSelection = false
    }
    
    //MARK: - Networking
    
    private func fetchUser() {
        self.showSpinner()
        
        SHOAPIClient.shared.getMe { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.user = object as? UserModel
            }
        }
    }
    
    private func setNotifications(withSlug slug: String, enabled: Bool) {
        self.showSpinner()
        
        SHOAPIClient.shared.enableNotifications(enabled, for: slug) { object, error, code in
            self.dismissSpinner()

            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
                self.tableView.reloadData() //Reload to set switch back
            } else {
                self.user = object as? UserModel
            }
        }
    }
    
    //MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user?.notificationPrefs.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationPreferenceTableViewCell = NotificationPreferenceTableViewCell.reusableCell(from: tableView)
        cell.separatorView.isHidden = true
        
        guard let preference = self.user?.notificationPrefs[indexPath.row] else {
            return cell
        }
        
        cell.label.text = preference.name
        cell.cellSwitch.isOn = preference.enabled
        cell.switchHandler = { [unowned self] isOn in
            self.setNotifications(withSlug: preference.slug, enabled: isOn)
        }
        cell.infoButtonTapHandler = { [unowned self] in
            self.showInfoAlert(withMessage: preference.description)
        }
        
        return cell
    }
    
    //MARK: - Helpers
    
    private func showInfoAlert(withMessage message: String) {
        let alertTitle = "ALERT_TITLE_INFO".localized
        let actions = [UIViewController.dismissAction()]
        let alert = UIViewController.alertWith(title: alertTitle,
                                               message: message,
                                               actions: actions)
        self.present(alert, animated: true)
    }
    
}
