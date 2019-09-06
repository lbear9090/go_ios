//
//  EventAttendeesViewController.swift
//  Go
//
//  Created by Lucky on 24/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class EventAttendeesViewController: SHOTableViewController {
    
    private let eventId: Int64
    var event: EventModel?
    private var user: UserModel?
    private var searchTerm: String?

    private lazy var friendshipManager = FriendshipManager(with: self)
    private lazy var searchManger = SearchControllerManager(with: self)
    
    init(withEventId eventId: Int64) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
        
        CacheManager.getCurrentUser { (user, error) in
            self.user = user
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControlDelegate = self
        
        let addFriendsButton = UIBarButtonItem(barButtonSystemItem: .add,
                                               target: self,
                                               action: #selector(navigateToAddFriends))
        if let user = self.user, user == self.event?.host {
            self.navigationItem.rightBarButtonItem = addFriendsButton
        }
    
        self.searchManger.addSearchController(to: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureTitle()
        self.refreshData()
    }
    
    @objc private func navigateToAddFriends() {
        let controller = SelectEventInviteesViewController(with: self.eventId)
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
    
    func configureTitle() {
        if let event = self.event {
            let config = LabelConfig(textFont: Font.semibold.withSize(.medium),
                                     textAlignment: .center,
                                     textColor: .darkText,
                                     backgroundColor: .clear,
                                     numberOfLines: 2)
            let titleLabel = UILabel(with: config)
            
            let attributedTitle = "EVENT_ATENDEES_TITLE".localized.toAttributedString(withFont: Font.semibold.withSize(.medium),
                                                                                      appendingString: event.title,
                                                                                      withFont: Font.regular.withSize(.extraSmall))
            titleLabel.attributedText = attributedTitle
            self.navigationItem.titleView = titleLabel
        }
        else {
            self.title = "EVENT_ATENDEES_TITLE".localized
        }
    }
    
    //MARK - UITableView datasource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FriendableUserTableViewCell = UserTableViewCell.reusableCell(from: tableView)
       
        if let attendee: AttendeeModel = item(at: indexPath),
            let user = attendee.user {
            cell.populate(with: user)
            cell.avatarBorderColor = attendee.status.indicatorColor
            cell.friendButton.setManager(self.friendshipManager)
            
            if let contribution = attendee.contribution {
                let symbol = contribution.amount.currency.symbol
                let amount = contribution.amount.cents/100
                cell.detailLabel.text = "\(symbol)\(amount)"
            }
            
            cell.attendingIconTappedHandler = { [unowned self] in
                let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
                controller.initialEventsType = .attending
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        return cell
    }
    
    //MARK - UITableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let attendee: AttendeeModel = item(at: indexPath),
            let user = attendee.user {
            let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

}

extension EventAttendeesViewController: SHORefreshable, SHOPaginatable {
    
    func loadData() {
        SHOAPIClient.shared.getEventAttendees(for: self.eventId,
                                              withOffset: self.offset,
                                              limit: self.limit,
                                              searchTerm: self.searchTerm) { (object, error, code) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.sharedCompletionHandler(object, error)
            }
        }
    }
    
}

// MARK: - SearchControllerManagerDelegate

extension EventAttendeesViewController: SearchControllerManagerDelegate {
    
    func searchWithTerm(_ term: String?) {
        self.searchTerm = term
        self.refreshData()
    }
    
    func searchCancelled() {
        self.searchTerm = nil
        self.refreshData()
    }
    
    func persistTerm(_ term: String?) {
        self.searchTerm = term
    }
    
}

