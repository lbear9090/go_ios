//
//  UserProfileViewController.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class CurrentUserProfileViewController: SHOTableViewController, SHOPaginatable, SHORefreshable {
    
    var endpointType: UserEndpointType = .me
    var initialEventsType: ProfileSegmentedControlType = .hosting
    var currentlySelectedEventsType: ProfileSegmentedControlType {
        return self.sectionHeaderView?.selectedSegmentType ?? self.initialEventsType
    }
    var userName: String?
    
    lazy var tableHeader: CurrentUserProfileHeaderView = {
        let header = CurrentUserProfileHeaderView()
        header.autoresize(for: self.view.bounds.size)
        header.friendLabelTapHandler = { [unowned self] in
            self.presentFriendsList()
        }
        return header
    }()
    
    var sectionHeaderView: UserProfileSectionHeaderView?
    
    override var emptyStateText: String {
        if currentlySelectedEventsType == .hosting {
            return "HOSTING_EVENTS_EMPTY_STATE".localized
        }
        return "EMPTY_STATE_MESSAGE".localized
    }
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavigationItemLogo()
        
        self.refreshControlDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBarForUseInTabBar()
        self.configureNavigationItem()
        self.getCachedUser()
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.estimatedRowHeight = 120
    }
    
    func configureNavigationItem() {
        let settingsButton = UIBarButtonItem(image: .settingsIcon,
                                             style: .plain,
                                             target: self,
                                             action: #selector(settingsButtonPressed))
        self.navigationItem.rightBarButtonItem = settingsButton
    }
    
    func getCachedUser() {
        CacheManager.getCurrentUser { (user, error) in
            if let user = user {
                self.userName = user.displayName
                self.tableHeader.populate(with: user)
                self.tableHeader.autoresize(for: self.view.bounds.size)
            }
            self.refreshUser(showSpinner: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.tableHeaderView = tableHeader
    }
    
    // MARK: - User Action
    
    @objc func settingsButtonPressed() {
        self.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    private func presentFriendsList() {
        let controller = CurrentUserFriendsViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Networking
    
    func refreshUser(showSpinner: Bool = true) {
        if showSpinner {
            self.showSpinner()
        }
        SHOAPIClient.shared.get(endpointType) { object, error, code in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let user = object as? UserModel {
                self.userName = user.displayName
                self.tableHeader.populate(with: user)
                self.tableHeader.autoresize(for: self.view.bounds.size)
            }
        }
    }
    
    func loadData() {
        self.sectionHeaderView?.setSegmentedControlEnabled(false)
        
        SHOAPIClient.shared.getEvents(withScope: self.currentlySelectedEventsType,
                                      for: self.endpointType,
                                      offset: self.offset,
                                      limit: self.limit) { (object, error, code) in
                                        self.sectionHeaderView?.setSegmentedControlEnabled(true)
                                        self.dismissSpinner()
                                        
                                        var events = [EventModel]()
                                        if let profileEvents = object as? ProfileEventsModel {
                                            events = profileEvents.events
                                            self.sectionHeaderView?.populate(with: profileEvents.meta)
                                        }
                                        self.sharedCompletionHandler(events, error)
        }
    }
    
}

// MARK: - UITableView Methods

extension CurrentUserProfileViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = items?.count ?? 0
        if count == 0 {
            return 1
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard (items?.count ?? 0) > 0 else {
            let cell: EmptyStateTableViewCell = EmptyStateTableViewCell.reusableCell(from: tableView)
            cell.emptyStateLabel.text = self.emptyStateText
            return cell
        }
        
        let cell: EventTableViewCell = EventTableViewCell.reusableCell(from: tableView)
        
        cell.attendingImageView.isHidden = self.currentlySelectedEventsType == .hosting
        if let event: EventModel = self.item(at: indexPath) {
            cell.configureCell(with: event)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = self.sectionHeaderView {
            return header
        } else {
            self.sectionHeaderView = UserProfileSectionHeaderView(selectedSegmentType: self.initialEventsType)
            self.sectionHeaderView!.delegate = self
            return self.sectionHeaderView
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if (items?.count ?? 0) > 0,
            let event: EventModel = self.item(at: indexPath) {
            
            let controller = EventViewController(withEventModel: event)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CurrentUserProfileViewController: UserProfileSectionHeaderViewDelegate {
    
    func didSelectSegmentedControlType(_ type: ProfileSegmentedControlType) {
        self.refreshData()
    }
    
    func didSelectEventCountView() {
        if let selectedSegment = self.sectionHeaderView?.selectedSegmentType {
            let dataProvider = EventsFriendsAttendingDataProvider(withSegmentType: selectedSegment,
                                                                  endpointType: self.endpointType)
            let controller = FeedViewController(with: dataProvider)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
