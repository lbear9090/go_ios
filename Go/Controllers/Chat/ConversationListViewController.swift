//
//  ConversationListViewController.swift
//  Go
//
//  Created by Lee Whelan on 23/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private struct ConversationListProperties {
    static let limit: Int = 10
    static let pagingStartIndex: Int = 9
}

class ConversationListViewController: SHOTableViewController, ConfigurableNavBarButtons {
    
    private lazy var searchManager = SearchControllerManager(with: self)
    private var searchTerm: String?
    
    override public var emptyStateText: String {
        return "CHAT_EMPTY_STATE".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CHAT_TITLE".localized
        self.refreshControlDelegate = self
        self.searchManager.addSearchController(to: self)
        self.limit = ConversationListProperties.limit
        self.pagingStartIndex = ConversationListProperties.pagingStartIndex
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarItem.badgeValue = nil
        UserDefaults.standard.set(0, forKey: UserDefaultKey.unreadMessageCount)
        AppDelegate.shared?.refreshAppIconBadgeNumber()
        
        self.configureNavBarButtons()
    }
    
    public func configureNavBarButtons() {
        let unreadCount = UserDefaults.standard.integer(forKey: UserDefaultKey.unreadNotificationCount)
        let notificationButtonImage: UIImage = unreadCount > 0 ? .notificationUnreadIcon : .notificationIcon
        
        let notificationButton = UIBarButtonItem(image: notificationButtonImage,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(notificationButtonTapped))
        self.navigationItem.rightBarButtonItem = notificationButton
        
        let createGroupButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                target: self,
                                                action: #selector(navigateToCreateGroup))
        self.navigationItem.leftBarButtonItem = createGroupButton
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationTableViewCell = ConversationTableViewCell.reusableCell(from: tableView)
        
        if let conversation: Conversation = item(at: indexPath) {
            cell.configure(conversation: conversation)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let conversation: Conversation = item(at: indexPath) {
            self.navigationController?.pushViewController(ConversationThreadViewController(conversation: conversation), animated: true)
            
            conversation.unreadCount = 0
            conversation.unread = false
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive,
                                                title: "TABLE_VIEW_ACTION_DELETE".localized,
                                                handler: { [weak self] (action, indexPath) in
                                                    if let conversation: Conversation = self?.item(at: indexPath) {
                                                        self?.deleteConversation(conversation)
                                                    }
        })
        
        let conversation: Conversation? = self.item(at: indexPath)
        let conversationMuted: Bool = conversation?.muted ?? false
        
        var muteTitle = "TABLE_VIEW_ACTION_MUTE".localized
        
        if conversationMuted {
            muteTitle = "TABLE_VIEW_ACTION_UNMUTE".localized
        }
        
        let muteAction = UITableViewRowAction(style: .normal,
                                              title: muteTitle) { [weak self] (action, indexPath) in
                                                if let conversation: Conversation = self?.item(at: indexPath) {
                                                    if conversation.muted {
                                                        self?.unmuteConversation(conversation)
                                                    }
                                                    else {
                                                        self?.muteConversation(conversation)
                                                    }
                                                }
        }
        
        return [deleteAction, muteAction]
    }
    
    // MARK: - User interaction
    
    @objc private func searchButtonTapped() {
        let controller = SearchSegmentedControlViewController.searchConfiguration()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func notificationButtonTapped() {
        self.navigationController?.pushViewController(NotificationsListViewController(), animated: true)
    }
    
    @objc private func navigateToCreateGroup() {
        self.navigationController?.pushViewController(AddParticipantsViewController(), animated: true)
    }

}

extension ConversationListViewController: SHORefreshable, SHOPaginatable {
    func loadData() {
        if let cachedConversations = try? CacheManager.getConversations(), let conversations = cachedConversations, self.offset == 0 {
            self.items = conversations
            self.dismissSpinner()
            self.tableView.reloadData()
        } else if self.items == nil {
            self.showSpinner()
        }
        
        SHOAPIClient.shared.conversations(for: self.searchTerm,
                                          from: self.offset,
                                          to: self.limit) { (data, error, code) in
                                            if let conversations = data as? [Conversation], self.offset == 0 {
                                                let _ = try? CacheManager.storeConversations(conversations)
                                            }
                                            
                                            self.dismissSpinner()
                                            self.sharedCompletionHandler(data, error)
        }
    }
    
    func deleteConversation(_ conversation: Conversation) {
        self.showSpinner()
        
        SHOAPIClient.shared.delete(conversation) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                self.refreshData()
            }
        }
    }
    
    func muteConversation(_ conversation: Conversation) {
        self.showSpinner()
        
        SHOAPIClient.shared.mute(conversation) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                conversation.muted = true
            }
        }
    }
    
    func unmuteConversation(_ conversation: Conversation) {
        self.showSpinner()
        
        SHOAPIClient.shared.unmute(conversation) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                conversation.muted = false
            }
        }
    }
    
}

extension ConversationListViewController: SearchControllerManagerDelegate {

    func searchWithTerm(_ term: String?) {
        self.offset = 0
        self.searchTerm = term
        self.refreshData()
    }

    func searchCancelled() {
        self.offset = 0
        self.searchTerm = nil
        self.refreshData()
    }
}
