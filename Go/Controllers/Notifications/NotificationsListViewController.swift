//
//  NotificationsListViewController.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import BulletinBoard

class NotificationsListViewController: SHOTableViewController {
    
    override public var emptyStateText: String {
        return "NOTIFICATIONS_EMPTY_STATE".localized
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    // This is also necessary when extending the superclass.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControlDelegate = self
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.estimatedRowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "NOTIFICATIONS_TITLE".localized
        
        UserDefaults.standard.set(0, forKey: UserDefaultKey.unreadNotificationCount)
        AppDelegate.shared?.refreshAppIconBadgeNumber()
    }
    
}

// MARK: - UITableViewDataSource

extension NotificationsListViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let notification: NotificationModel = item(at: indexPath),
            let notificationType = notification.type else {

            assertionFailure("Unable to process notification object")
            return UITableViewCell()
        }
        
        switch notificationType {
        case .friendRequest:
            let cell: RequestNotificationCell = RequestNotificationCell.reusableCell(from: tableView)
            cell.configure(with: notification)
            cell.actionHandler = { [unowned self, cell] accepted in
                if let requestId = notification.resources?.friendRequest?.id {
                    self.acceptFriendRequest(accepted, withId: requestId)
                    cell.enableButtons(false)
                }
            }
            return cell
            
        case .eventRequestOwner:
            let cell: RequestNotificationCell = RequestNotificationCell.reusableCell(from: tableView)
            cell.configure(with: notification)
            cell.actionHandler = { [unowned self] accepted in
                
                if let event = notification.resources?.event,
                    let attendee = notification.resources?.requestingAttendee,
                    let request = attendee.request {
                    
                    self.acceptAttendanceRequest(accepted,
                                                 eventId: event.eventId,
                                                 attendeeId: attendee.id,
                                                 requestId: request.id)
                }
            }
            return cell
            
        case .eventInvite, .eventRequestResponse:
            let cell: InvitationNotificationCell = InvitationNotificationCell.reusableCell(from: tableView)
            cell.configure(with: notification)
            return cell
        
        default:
            let cell: NotificationCell = NotificationCell.reusableCell(from: tableView)
            cell.configure(with: notification)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension NotificationsListViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if let notification: NotificationModel = item(at: indexPath),
            let notificationType = notification.type {
            
            SHOAPIClient.shared.readNotification(withId: notification.notificationId)
            
            switch notificationType {
            case .general:
                self.showInPopUp(notification: notification)
            case .friendshipCreated, .eventRequestOwner:
                if let user = notification.resources?.user {
                    self.show(user)
                }
            case .friendRequest:
                if let user = notification.resources?.friendRequest?.requestingUser {
                    self.show(user)
                }
            case .eventInvite, .eventShare, .eventRequestResponse, .upcomingEvent:
                if let event = notification.resources?.event {
                    self.show(event)
                }
            case .eventAttendee:
                if let event = notification.resources?.event {
                    self.showAttendees(event)
                }
            case .timelineLike:
                if let event = notification.resources?.event {
                    self.showEventTimeline(event)
                }
            case .timelineComment:
                if let timelineItem = notification.resources?.timelineItem {
                    self.showComments(timelineItem)
                }
            case .fbEventsImport:
                if let fbEvent = notification.resources?.facebookEvent {
                    self.showPopup(title: "",
                                   message: fbEvent.message)
                }
            case .messageSent:
                if let conversationID = notification.resources?.conversationID {
                    self.showConversation(id: conversationID)
                }
            case .eventCancelled:
                break
            }
        }
    }
    
}

// MARK: - Networking

extension NotificationsListViewController: SHORefreshable, SHOPaginatable {
    
    func loadData() {
        if let cachedNotifications = try? CacheManager.getNotifications(), let notifications = cachedNotifications, self.offset == 0 {
            self.items = notifications
            self.dismissSpinner()
            self.tableView.reloadData()
        } else if self.items == nil {
            self.showSpinner()
        }
        
        SHOAPIClient.shared.getNotifications(withOffset: self.offset, limit: self.limit) { object, error, code in
            if let notifications = object as? [NotificationModel], self.offset == 0 {
                let _ = try? CacheManager.storeNotifications(notifications)
            }

            self.dismissSpinner()
            self.sharedCompletionHandler(object, error)
        }
    }
    
    func acceptFriendRequest(_ accept: Bool, withId requestId: Int64) {
        if accept {
            SHOAPIClient.shared.acceptFriendRequest(withId: requestId,
                                                    completionHandler: self.sharedRequestCompletion)
        } else {
            SHOAPIClient.shared.rejectFriendRequest(withId: requestId,
                                                    completionHandler: self.sharedRequestCompletion)
        }
    }
    
    func acceptAttendanceRequest(_ accept: Bool, eventId: Int64, attendeeId: Int64, requestId: Int64) {
        if accept {
            SHOAPIClient.shared.acceptAttendanceRequest(for: eventId,
                                                        attendeeId: attendeeId,
                                                        requestId: requestId,
                                                        completionHandler: self.sharedRequestCompletion)
        } else {
            SHOAPIClient.shared.rejectAttendanceRequest(for: eventId,
                                                        attendeeId: attendeeId,
                                                        requestId: requestId,
                                                        completionHandler: self.sharedRequestCompletion)
        }
    }
    
    func sharedRequestCompletion(_ data: Any?, _ error: Error?, _ statusCode: Int) {
        if let error = error {
            self.showErrorAlertWith(message: error.localizedDescription)
        } else {
            self.refreshData()
        }
    }

}

// MARK: - Action Handler

extension NotificationsListViewController {
    
    func showInPopUp(notification: NotificationModel) {
        if let message = notification.resources?.genericBundle?.message,
            let title = notification.resources?.genericBundle?.title,
            let platformImages = notification.resources?.genericBundle?.platform.images,
            let urlString = platformImages.mediumUrl,
            let imageURL = URL(string: urlString) {
            
            self.showPopup(title: title,
                           message: message,
                           imageURL: imageURL)
        }
    }
    
    func show(_ user: UserModel) {
        let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func show(_ event: EventModel) {
        self.navigationController?.pushViewController(EventViewController(withId: event.eventId), animated: true)
    }
    
    func showAttendees(_ event: EventModel) {
        self.navigationController?.pushViewController(EventAttendeesViewController(withEventId: event.eventId), animated: true)
    }
    
    func showEventTimeline(_ event: EventModel) {
        let dataProvider = TimelineDataProvider(eventId: event.eventId)
        let controller = EventTimelineViewController(with: dataProvider,
                                                     eventId: event.eventId,
                                                     eventTitle: event.title)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showComments(_ timeline: TimelineModel) {
        let controller = CommentsViewController(eventId: timeline.associatedEventId, timelineId: timeline.id)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showConversation(id: Int64) {
        if let messageVC = ConversationThreadViewController(conversationID: id) {
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    
    private func showPopup(title: String, message: String, imageURL: URL? = nil) {
        let page = PageBulletinItem(title: title)
        page.descriptionText = message
        page.actionButtonTitle = "CLOSE".localized
        page.alternativeButtonTitle = nil
        page.interfaceFactory.tintColor = .green
        page.image = .notificationPlaceholder
        
        if let imageURL = imageURL {
            UIImageView().kf.setImage(with: imageURL,  completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    page.image = image
                }
            })
        }
        
        let manager = BulletinManager(rootItem: page)
        manager.prepare()
        manager.presentBulletin(above: self)
        
        page.actionHandler = { (item: PageBulletinItem) in
            manager.dismissBulletin()
        }
    }
}
