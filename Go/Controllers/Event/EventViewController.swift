//
//  EventViewController.swift
//  Go
//
//  Created by Lucky on 18/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import MapKit
import AVKit
import EventKit

enum EventDetailsSection: Int {
    case header
    case info
    case description
    case attendees
    case events
    case SECTIONS_COUNT
    
    var headerHeight: CGFloat {
        switch self {
        case .header:
            return 393.0
        case .info, .description:
            return 0.0
        default:
            return 30.0
        }
    }
    
    var headerTitle: String? {
        switch self {
        case .attendees:
            return "ATTENDEES".localized
        case .events:
            return "RELATED_EVENTS".localized
        default:
            return nil
        }
    }
}

enum EventInfoRow: Int {
    case location
    case contribution
    case bring
    case ROW_COUNT
}

enum EventDescriptionRow: Int {
    case text
    case buyTickets
    case categories
    case ROW_COUNT
}

class EventViewController: SHOTableViewController, VideoPlayerViewDelegate {
    
    public var animateButton: Bool = false
    
    private var currentUser: UserModel?
    private var isEventOwner: Bool = false
    private var isEventDataFetched: Bool = false
    private let eventId: Int64
    
    private var event: EventModel? {
        didSet {
            self.refresh()
        }
    }
    
    var accessToken: String! = {
        return SHOSessionManager.shared.bearerToken
    }()
    
    private var headerView: EventHeaderView?
    private lazy var contributionAlertManager = ContributionAlertManager(for: self)
    private lazy var optionsAlertManager = OptionsAlertManager(for: self)
    private lazy var stripeCardManager = StripeCardManager(withController: self)
    private lazy var friendshipManager = FriendshipManager(with: self)
    private lazy var calendarManager = CalendarManager(withController: self)
    
    init(withId eventId: Int64) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
        CacheManager.getCurrentUser(withFallbackPolicy: .network(controller: self)) { (user, error) in
            self.currentUser = user
        }
    }
    
    init(withEventModel eventModel: EventModel) {
        self.event = eventModel
        self.eventId = eventModel.eventId
        super.init(nibName: nil, bundle: nil)
        CacheManager.getCurrentUser(withFallbackPolicy: .network(controller: self)) { (user, error) in
            self.currentUser = user
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optionsBarButton = UIBarButtonItem(image: .actionButton,
                                               style: .plain,
                                               target: self,
                                               action: #selector(optionsButtonTapped))
        self.navigationItem.rightBarButtonItem = optionsBarButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = "EVENT_DETAILS_TITLE".localized
        
        self.getEvent()
        
        if self.animateButton && !self.isEventOwner {
            self.headerView?.attendButton.onTap()
            self.animateButton = false
        }
    }
    
    private func refresh() {
        self.tableView.reloadData()
        if let event = self.event {
            self.headerView?.populate(with: event)
            self.isEventOwner = (self.currentUser == event.host)
            self.headerView?.attendButton.isUserInteractionEnabled = !self.isEventOwner
        }
    }
    
    
    // MARK: User actions
    
    @objc private func optionsButtonTapped() {
        if let event = self.event {
            self.optionsAlertManager.showOptions(forEvent: event) { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func getDirections() {
        if let lat = event?.latitude,
            let lng = event?.longitude {

            let urlString = String(format: Constants.googleMapsDirectionsURL, lat, lng)
            
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: Networking
    
    private func getEvent() {
        if self.event == nil {
            self.showSpinner()
        }
        SHOAPIClient.shared.getEvent(withId: self.eventId) { (object, error, code) in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else if let event = object as? EventModel {
                self.isEventDataFetched = true
                if self.event == nil {
                    self.event = event
                } else {
                    self.event?.updateWith(event: event)
                }
                self.refresh()
            } else {
                self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
            }
        }
    }
    
    private func addContribution(of amount: Int, toEvent event: EventModel) {
        guard let attendeeId = event.userAttendance?.id else {
            self.showSpinner()
            SHOAPIClient.shared.setAtttendanceStatus(.pending, forEventId: event.eventId) { object, error, code in
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                } else if let attendance = object as? AttendeeModel {
                    event.userAttendance = attendance
                    self.addContribution(of: amount, toEvent: event)
                } else {
                    self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
                }
            }
            return
        }
        
        self.showSpinner()
        SHOAPIClient.shared.addContribution(of: amount, to: event.eventId, from: attendeeId) { (object, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                if (error as NSError).code == APIConstants.noPaymentMethodCode {
                    
                    self.showAddCardAlert(with: error) { [unowned self] succeeded in
                        if succeeded {
                            self.addContribution(of: amount, toEvent: event)
                        }
                    }

                } else {
                    self.showErrorAlertWith(message: error.localizedDescription)
                }
            } else {
                let okAction = UIViewController.okAction { [weak self] (action) in
                    self?.setAttendanceStatus(to: .going)
                }
                let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                       message: "EVENT_CONTRIBUTION_SUCCESS_MSG".localized,
                                                       actions: [okAction])
                self.present(alert, animated: true)
            }
        }
    }
    
    private func showAddCardAlert(with error: Error, completionHandler: @escaping (Bool) -> Void) {
        
        let okAction = UIViewController.okAction { [unowned self] action in
            self.stripeCardManager.addCard { (object, error) in
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                completionHandler(error == nil)
            }
        }
        
        let cancelAction = UIViewController.cancelAction()
        
        let alert = UIViewController.alertWith(title:"ERROR_ALERT_TITLE".localized,
                                               message: error.localizedDescription,
                                               actions: [okAction, cancelAction])
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - EventHeaderViewDelegate

extension EventViewController: EventHeaderViewDelegate {
    
    func showProfileForUser(_ user: UserModel) {
        let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapForwardButton(_ button: UIButton) {
        let controller = EventForwardingViewController(eventId: self.eventId)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapTimelineButton(_ button: UIButton) {
        if let event = self.event {
            let dataProvider = TimelineDataProvider(eventId: event.eventId)
            let controller = EventTimelineViewController(with: dataProvider,
                                                         eventId: event.eventId,
                                                         eventTitle: event.title)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didTapChatButton(_ button: UIButton) {
        guard
            let event = self.event, event.conversationID != -1,
            let messagesVC = ConversationThreadViewController(conversationID: event.conversationID)
        else {
            return
        }
        
        self.navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    func showShareOptionsFor(event: EventModel) {
        self.optionsAlertManager.configureBranchObjectForSharing(event)
        self.optionsAlertManager.showSharingOptions(event: event)
    }
    
    func getContribution() {
        guard let event = self.event else {
            return
        }
        
        self.contributionAlertManager.showAlert(for: event) { [unowned self] amount in
            self.addContribution(of: amount, toEvent: event)
        }
    }
    
    
    public func setAttendanceStatus(to status: AttendanceStatus) {
        guard let event = self.event else {
            return
        }
        
        self.showSpinner()
        
        if let attendance = event.userAttendance {
            SHOAPIClient.shared.updateAttendanceStatus(to: status,
                                                       forAttendeeId: attendance.id,
                                                       forEventId: event.eventId,
                                                       completionHandler: self.sharedCompletionHandler)
        } else {
            SHOAPIClient.shared.setAtttendanceStatus(status,
                                                     forEventId: event.eventId,
                                                     completionHandler: self.sharedCompletionHandler)
        }
    }
    
    private func sharedCompletionHandler(_ object: Any?, _ error: Error?, _ statusCode: Int) -> Void {
        self.dismissSpinner()
        
        if let error = error {
            self.showErrorAlertWith(message: error.localizedDescription, completion: nil)
        } else if let attendance = object as? AttendeeModel {
            
            let section = EventDetailsSection.header.rawValue
            if let header = self.tableView(tableView, viewForHeaderInSection: section) as? EventHeaderView {
                header.setAttendanceState(to: attendance.status)
            }
            
            if attendance.request?.status == .pending {
                let alert = UIViewController.alertWith(title: "EVENT_ATTENDANCE_REQUESTED_TITLE".localized,
                                                       message: "EVENT_ATTENDANCE_REQUESTED_MSG".localized)
                alert.addAction(UIViewController.okAction())
                self.present(alert, animated: true)
            }
            
            if let event = self.event, let user = self.currentUser {
                if let attendance = object as? AttendeeModel {
                    event.userAttendance = attendance
                }
                self.calendarManager.handleEvent(event, forUser: user)
            }
            
        } else {
            self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized, completion: nil)
        }
    }

}

// MARK: - UITableView datasource

extension EventViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return EventDetailsSection.SECTIONS_COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch EventDetailsSection(rawValue: section) {
        case .info?:
            return 3
        case .description?:
            return EventDescriptionRow.ROW_COUNT.rawValue
        
        case .attendees?:
            if let attendeeCount = self.event?.attendees.count,
                attendeeCount > 0 {
                return attendeeCount + 1
            }
            return 0
       
        case .events?:
            return self.event?.relatedEvents.count ?? 0
        
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = EventDetailsSection(rawValue: indexPath.section), section == .description,
            let row = EventDescriptionRow(rawValue: indexPath.row), row == .buyTickets {
            return self.event?.eventTicketURL == nil ? 0 : UITableViewAutomaticDimension
        }
        if let sectionInfo = EventDetailsSection(rawValue: indexPath.section), sectionInfo == .info,
            let row = EventInfoRow(rawValue: indexPath.row) {
            switch row {
            case .contribution:
                return (isEventDataFetched && self.event?.contribution == nil) ? 0 : UITableViewAutomaticDimension
            case .bring:
                return (isEventDataFetched && self.event?.bring?.isEmpty ?? true) ? 0 : UITableViewAutomaticDimension
            default :
                return UITableViewAutomaticDimension
            }
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch EventDetailsSection(rawValue: indexPath.section) {
        case .info?:
            return self.tableView(tableView, infoCellAt: indexPath.row)

        case .description?:
            return self.tableView(tableView, descriptionCellAt: indexPath.row)
            
        case .attendees?:
            if tableView.isFinalRowInSection(at: indexPath) {
                let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView)
                
                cell.textLabel?.textColor = .green
                cell.accessoryType = .disclosureIndicator
                
                if self.event?.host == self.currentUser {
                    cell.textLabel?.text = "VIEW_ALL_ADD_MORE".localized
                } else {
                    cell.textLabel?.text = "VIEW_ALL".localized
                }
                
                return cell
            }
            let cell: FriendableUserTableViewCell = FriendableUserTableViewCell.reusableCell(from: tableView)
            if
                let attendee = self.event?.attendees[indexPath.row],
                let user = attendee.user {
                
                cell.populate(with: user)
                cell.avatarBorderColor = attendee.status.indicatorColor
                cell.friendButton.setManager(friendshipManager)
                
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
            
        case .events?:
            let cell: EventTableViewCell = EventTableViewCell.reusableCell(from: tableView)
            if let event = self.event?.relatedEvents[indexPath.row] {
                cell.configureCell(with: event)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    private func tableView(_ tableView: UITableView, infoCellAt row: Int) -> UITableViewCell {
        let cell: IconLabelTableViewCell = IconLabelTableViewCell.reusableCell(from: tableView)
        cell.selectionStyle = .none
        switch EventInfoRow(rawValue: row) {
        case .location?:
            cell.iconLabel.iconImageView.image = .location
            cell.iconLabel.text = self.event?.address
            cell.subLabel.text = "EVENT_DETAILS_GET_DIRECTIONS".localized
            cell.subLabel.textColor = .green
            let directionsTGR = UITapGestureRecognizer(target: self, action: #selector(getDirections))
            cell.subLabel.isUserInteractionEnabled = true
            cell.subLabel.addGestureRecognizer(directionsTGR)
        case .contribution?:
            cell.loadingSkeleton.isHidden = false
            cell.animateLoader()
            if let contribution = event?.contribution {
                cell.iconLabel.iconImageView.image = .contributionAmount
                let amountString = "\(contribution.amount.currency.symbol)\(contribution.amount.cents/100)"
                cell.iconLabel.text = "\(amountString) \("EVENT_DETAILS_CONTRIBUTION".localized)"
                cell.subLabel.text = contribution.reason
                cell.subLabel.textColor = .lightText
                cell.loadingSkeleton.isHidden = true
            } else {
                if isEventDataFetched {
                    hideCell(cell: cell)
                }
            }
        case .bring?:
            cell.loadingSkeleton.isHidden = false
            cell.animateLoader()
            if !(event?.bring?.isEmpty ?? true) {
                cell.iconLabel.iconImageView.image = .bring
                cell.iconLabel.text = "EVENT_DETAILS_BRING".localized
                cell.subLabel.text = event?.bring
                cell.subLabel.textColor = .lightText
                cell.loadingSkeleton.isHidden = true
            } else {
                if isEventDataFetched {
                    hideCell(cell: cell)
                }
            }
        default:
            break
        }
        return cell
    }
    
    private func hideCell(cell: IconLabelTableViewCell) {
        cell.loadingSkeleton.isHidden = true
        cell.iconLabel.iconImageView.image = nil
        cell.iconLabel.text = ""
    }
    
    private func tableView(_ tableView: UITableView, descriptionCellAt row: Int) -> UITableViewCell {
        switch EventDescriptionRow(rawValue: row) {
        case .text?:
            let cell: TextViewTableViewCell = TextViewTableViewCell.reusableCell(from: tableView)
            cell.textView.text = event?.description
            cell.textView.font = Font.regular.withSize(.small)
            cell.textView.isUserInteractionEnabled = false
            return cell
        case .buyTickets?:
            let cell: ButtonTableViewCell = ButtonTableViewCell.reusableCell(from: tableView)
            cell.button.setTitle("EVENT_DETAILS_PURCHASE_TICKETS".localized, for: .normal)
            cell.contentView.isHidden = (self.event?.eventTicketURL == nil) 
            cell.actionHandler = { [unowned self] (cell) in
                if var ticketURL = self.event?.eventTicketURL,
                    let bearerToken = SHOSessionManager.shared.bearerToken?.components(separatedBy: " ").last {
                    ticketURL.append("?token=\(bearerToken)")
                    SHOWebViewController.presentModally(withUrlString: ticketURL,
                                                        fromController: self)
                }
            }
            return cell
        case .categories?:
            let cell: TagListTableViewCell = TagListTableViewCell.reusableCell(from: tableView)
            
            if let categories = event?.categories?.split(separator: "#").compactMap({ substring -> String? in
                return String(substring).trimmingCharacters(in: .whitespaces)
            }) {
                cell.setTags(categories)
            }
            
            cell.tagSelectedHandler = { [unowned self] tagText in
                let controller = FeedViewController(with: TagEventsDataProvider(withTag: tagText))
                controller.title = "#\(tagText)"
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            return cell
            
        default:
            fatalError("No cell returned for section")
        }
    }
}

// MARK: - UITableView delegate
    
extension EventViewController {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == EventDetailsSection.header.rawValue {

            if let header = self.headerView {
                return header
            } else {
                let header: EventHeaderView = EventHeaderView(frame: .zero)
                header.delegate = self
                header.videoPlayer.videoDelegate = self
                self.headerView = header
                
                if let event = self.event {
                    self.headerView?.populate(with: event)
                    self.isEventOwner = (self.currentUser == event.host)
                    self.headerView?.attendButton.isUserInteractionEnabled = !self.isEventOwner
                }
                
                return self.headerView
            }
        }
        
        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
        let header = SectionHeaderView(frame: frame)
        header.backgroundColor = .white
        header.leftLabel.text = EventDetailsSection(rawValue: section)?.headerTitle
        
        if section == EventDetailsSection.attendees.rawValue,
            let attendingCount = event?.friendsAttendingCount, attendingCount > 0 {
            let avatarURLs = event?.attendingFriends.compactMap { user -> String? in
                return user.avatarImage?.smallUrl
            }
            header.avatarImageUrls = avatarURLs ?? []
            header.rightLabel.text = String(format: "EVENT_DETAILS_FRIENDS_ATTENDING".localized, attendingCount)
        }
        
        if let event = self.event {
            self.headerView?.populate(with: event)
            self.isEventOwner = (self.currentUser == event.host)
            self.headerView?.attendButton.isUserInteractionEnabled = !self.isEventOwner
        }
        
        header.layoutIfNeeded()
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return EventDetailsSection(rawValue: section)?.headerHeight ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch EventDetailsSection(rawValue: indexPath.section) {
            
        case .attendees?:
            if tableView.isFinalRowInSection(at: indexPath) {
                let attendeesVC = EventAttendeesViewController(withEventId: self.eventId)
                attendeesVC.event = self.event
                self.navigationController?.pushViewController(attendeesVC, animated: true)
            } else {
                if let user = self.event?.attendees[indexPath.row].user {
                    let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
        case .events?:
            if let event = self.event?.relatedEvents[indexPath.row] {
                self.navigationController?.pushViewController(EventViewController(withEventModel: event),
                                                              animated: true)
            }
            
        default:
            break
        }
    }
}

extension UITableView {
    
    func isFinalRowInSection(at indexPath: IndexPath) -> Bool {
        let numRows = self.numberOfRows(inSection: indexPath.section)
        return indexPath.row == numRows - 1
    }
    
}
