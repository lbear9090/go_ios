//
//  ContactsFriendsViewController.swift
//  Go
//
//  Created by Lucky on 04/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Contacts

class ContactsFriendsViewController: SHOTableViewController, SearchSegmentController {
    
    var segmentTitle: String = "FIND_FRIENDS_CONTACTS".localized
    var lastSearchedTerm: String?
    var requestContacts: [ContactModel] = []
    var returnedContacts: [ContactModel] = []
    
    private let customIndicator = SHOSyncingIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    private var refreshControl: UIRefreshControl?
    
    private lazy var friendManager = FriendshipManager(with: self)
    
    // True if the custom indicator is shown
    private var isRefreshing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if there are stored contacts. Otherwise fetch them.
        if let cachedContacts = try? CacheManager.getContacts(), let contacts = cachedContacts {
            self.returnedContacts = contacts
            self.tableView.reloadData()
            
            self.addSyncingView()
            self.fetchContacts()
        }
        else {
            self.showSpinner()
            self.fetchContacts()
        }
    }
    
    private func fetchContacts() {
        let contactStore = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor
        ]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        do {
            self.requestContacts.removeAll()
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                let phoneNumbers = contact.phoneNumbers.compactMap({ (phoneNumber) -> String? in
                    return phoneNumber.value.stringValue
                })
                
                let email = contact.emailAddresses.first(where: {
                    $0.identifier == CNLabelHome
                }) ?? contact.emailAddresses.first
                
                var contactName = String()
                if !contact.givenName.isEmpty || !contact.familyName.isEmpty {
                    contactName = contact.givenName
                    contactName.append(contact.givenName.isEmpty || contact.familyName.isEmpty  ? "" : " ")
                    contactName.append(contact.familyName)
                } else {
                    contactName = contact.organizationName
                }
                
                let contactModel = ContactModel(name: contactName,
                                                phoneNumbers: phoneNumbers,
                                                email: email?.value as String?)
                
                self.requestContacts.append(contactModel)
            }
        } catch let error as NSError {
            self.handleContactRequestError(error)
        }
        
        self.loadResults(for: self.lastSearchedTerm)
    }
    
    //MARK: - Networking
    
    func loadResults(for term: String?) {
        SHOAPIClient.shared.findFriends(from: self.requestContacts,
                                        matching: term) { (object, error, code) in

            self.dismissSpinner()
            self.removeSyncingView()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let result = object as? ContactsFetchModel {
                self.returnedContacts = result.contacts
                // Store the contacts fetched
                try? CacheManager.storeContacts(self.returnedContacts)
            } else {
                self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
            }

            // Reload the tableView and end refreshing indicator if exists
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func inviteContact(_ contact: ContactModel) {
        self.showSpinner()
        SHOAPIClient.shared.inviteContact(contact) { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
                
            } else if let response = object as? ResponseMessageModel {
                self.loadResults(for: self.lastSearchedTerm)
                let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                       message: response.message)
                alert.addAction(UIViewController.okAction())
                self.present(alert, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.addSyncingView()
        self.fetchContacts()
    }
    
    //MARK: - TableView datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.returnedContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InviteContactTableViewCell = InviteContactTableViewCell.reusableCell(from: tableView)
        
        let contact = self.returnedContacts[indexPath.row]
        cell.nameLabel.text = contact.name
        
        if contact.invited {
            cell.inviteLabel.text = "FIND_FRIENDS_INVITED".localized
            cell.inviteLabel.textColor = .green
        } else {
            cell.inviteLabel.text = self.inviteLabelText
            cell.inviteLabel.textColor = .lightText
        }
        
        return cell
    }
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = self.returnedContacts[indexPath.row]
        if !contact.invited { //Don't invite if previously invited
            if contact.phoneNumbers.count > 1 {
                self.showSelectNumberAlert(for: contact)
            } else {
                self.inviteContact(contact)
            }
        }
    }
    
    //MARK: - Helpers
    
    var inviteLabelText: String {
        return "FIND_FRIENDS_INVITE".localized
    }
    
    private func handleContactRequestError(_ error: NSError) {
        if error.code != 100 { //Access denied error code
            self.showErrorAlertWith(message: error.localizedDescription)
            return
        }
        
        let alert = UIAlertController.alertWith(title: error.localizedDescription,
                                                message: error.localizedFailureReason!)
        
        let allowAccessAction = UIAlertAction(title: "ALLOW_CONTACTS_ACCESS".localized, style: .default) { action in
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        
        alert.addAction(allowAccessAction)
        alert.addAction(UIViewController.dismissAction())
        
        self.present(alert, animated: true)
    }
    
    private func showSelectNumberAlert(for contact: ContactModel) {
        var actions: [UIAlertAction] = contact.phoneNumbers.map { (number) -> UIAlertAction in
            return UIAlertAction(title: number, style: .default) { [unowned self] action in
                contact.selectedNumber = number
                self.inviteContact(contact)
            }
        }
        
        actions.append(UIViewController.cancelAction())
        
        if let actionSheet = UIViewController.actionSheetWith(title: "INVITE_SELECT_NUMBER".localized,
                                                              message: nil,
                                                              actions: actions) {
            self.present(actionSheet, animated: true)
        }
    }
    
    // Adds the custom syncing indicator
    private func addSyncingView() {
        self.isRefreshing = true
        self.tableView.tableHeaderView = customIndicator
        self.customIndicator.startIndicatorAnimation()
    }
    
    // Removes the custom syncing indicator
    private func removeSyncingView() {
        self.isRefreshing = false
        self.customIndicator.stopIndicatorAnimation()
        self.tableView.tableHeaderView = nil
    }
    
    // Check if the app is already syncing the contacts
    override func refreshData() {
        super.refreshData()
        
        if self.isRefreshing {
            self.refreshControl?.endRefreshing()
        } else {
            self.fetchContacts()
        }
    }
}

