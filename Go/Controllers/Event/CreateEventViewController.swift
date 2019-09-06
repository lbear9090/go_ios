//
//  AddEventViewController.swift
//  Go
//
//  Created by Lucky on 26/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import CoreLocation
import Photos
import AVKit

public enum CreateEventSection: Int {
    case details
    case location
    case tickets
    case categories
    case publicByInviteOptions
    case privateEvent
    case limitedSpace
    case actions
    case contributions
    case bring
    case SECTIONS_COUNT
    
    var title: String? {
        switch self {
        case .details:
            return "ADD_EVENT_DETAILS".localized
        case .location:
            return "ADD_EVENT_LOCATION".localized
        case .tickets:
            return "ADD_EVENT_SELL_TICKETS".localized
        case .categories:
            return "ADD_EVENT_CATEGORIES".localized
        case .publicByInviteOptions:
            return "ADD_EVENT_OPTIONS".localized
        case .contributions:
            return "ADD_EVENT_CONTRIBUTIONS".localized
        case .bring:
            return "ADD_EVENT_BRING".localized
        default:
            return nil
        }
    }
}

public enum EventDetailsRow: Int {
    case title
    case description
    case time
    case date
    case adultOnly
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .title:
            return "DETAILS_TITLE".localized
        case .description:
            return "DETAILS_DESCRIPTION".localized
        case .time:
            return "DETAILS_TIME".localized
        case .date:
            return "DETAILS_DATE".localized
        case .adultOnly:
            return "DETAILS_ADULT_ONLY".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .title:
            return .title
        case .description:
            return .description
        case .time:
            return .time
        case .date:
            return .date
        case .adultOnly:
            return .adultOnly
        default:
            return nil
        }
    }
}

public enum SellTicketsRow: Int {
    case enable
    case link
    case description
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .enable:
            return "ENABLE_TICKET_SALES".localized
        case .link:
            return "TICKET_LINK".localized
        case .description:
            return "TICKET_DESCRIPTION".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .enable:
            return .ticket
        case .link:
            return .link
        default:
            return nil
        }
    }
}

public enum PublicByInviteRow: Int {
    case publicByInvite
    case description
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .publicByInvite:
            return "OPTIONS_PUBLIC_BY_INVITE".localized
        case .description:
            return "OPTIONS_PUBLIC_BY_INVITE_DESCRIPTION".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .publicByInvite:
            return .publicInvitation
        default:
            return nil
        }
    }
}

public enum PrivateEventRow: Int {
    case toggle
    case description
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .toggle:
            return "OPTIONS_PRIVATE".localized
        case .description:
            return "OPTIONS_FRIENDS_DESCRIPTION".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .toggle:
            return .privateEvent
        default:
            return nil
        }
    }
}

public enum LimitedSpaceRow: Int {
    case limitedSpaces
    case guestCap
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .limitedSpaces:
            return "OPTIONS_LIMITED_SPACES".localized
        case .guestCap:
            return "OPTIONS_GUEST_CAP".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .limitedSpaces:
            return .limitedSpace
        case .guestCap:
            return .guestCap
        default:
            return nil
        }
    }
}

public enum ActionsRow: Int {
    case forwarding
    case chatEnabled
    case timelineEnabled
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .forwarding:
            return "OPTIONS_FORWARDING".localized
        case .chatEnabled:
            return "OPTIONS_CHAT".localized
        case .timelineEnabled:
            return "OPTIONS_TIMELINE".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .forwarding:
            return .eventForwarding
        case .chatEnabled:
            return .allowChat
        case .timelineEnabled:
            return .allowTimeline
        default:
            return nil
        }
    }
}

public enum ContributionsRow: Int {
    case enabled
    case amount
    case reason
    case optional
    case ROW_COUNT
    
    var title: String? {
        switch self {
        case .enabled:
            return "CONTRIBUTIONS_ENABLED".localized
        case .amount:
            return "CONTRIBUTIONS_AMOUNT".localized
        case .reason:
            return "CONTRIBUTIONS_REASON".localized
        case .optional:
            return "CONTRIBUTIONS_OPTIONAL".localized
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .enabled:
            return .contribution
        case .amount:
            return .contributionAmount
        case .reason:
            return .contributionReason
        case .optional:
            return .contributionOptional
        default:
            return nil
        }
    }
}

private let DescriptionCellReuseIdentifier: String = "DescriptionCellReuseIdentifier"
private let FriendsCellReuseIdentifier: String = "FriendsCellReuseIdentifier"
private let FriendsDescriptionCellReuseIdentifier: String = "FriendsDescriptionCellReuseIdentifier"
private let PublicByInviteDescriptionCellReuseIdentifier: String = "PublicByInviteDescriptionCellReuseIdentifier"

class CreateEventViewController: SHOTableViewController {
    
    //MARK: - Properties
    
    public var requestModel = AddEventRequestModel()
    private var user: UserModel?
    private var selectedImage: UIImage?
    private var selectedVideoUrl: URL?
    private var createdEvent: EventModel?

    public lazy var headerView: AddEventHeaderView = {
        let width = self.view.frame.width
        let headerFrame = CGRect(x: 0, y: 0, width: width, height: Constants.mediaHeight)
        let header = AddEventHeaderView(frame: headerFrame)
        header.delegate = self
        header.videoPlayer.videoDelegate = self
        return header
    }()
    
    public lazy var buttonView: ButtonView = {
        let size = CGSize(width: self.view.bounds.width, height: 60)
        let frame = CGRect(origin: .zero, size: size)
        let view = ButtonView(frame: frame)
        
        view.button.setTitle("CREATE_EVENT".localized, for: .normal)
        view.button.addTarget(self,
                              action: #selector(actionButtonPressed),
                              for: .touchUpInside)
        return view
    }()
    
    private lazy var imagePicker = SHOImagePickerUtils(with: self)
    private lazy var calendarManager = CalendarManager(withController: self)
    
    //MARK: - View callbacks
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "ADD_EVENT_TITLE".localized
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //https://stackoverflow.com/a/27244469/
        self.tableView.tableHeaderView = self.headerView
        self.tableView.tableFooterView = self.buttonView
    }
    
    //MARK: - User interaction
    
    @objc public func actionButtonPressed() {
        self.view.endEditing(true)
        
        switch self.requestModel.validate() {
        case .valid:
            self.handleMediaUpload { error in
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                } else {
                    self.createEvent()
                }
            }
            
        case .invalid(let errorString):
            self.showErrorAlertWith(message: errorString)
        }
    }
    
    @objc private func adultOnlySwitchToggled(_ sender: UISwitch) {
        self.requestModel.eighteenPlus = sender.isOn
    }
    
    @objc private func ticketSaleSwitchToggled(_ sender: UISwitch) {
        self.requestModel.ticketsSaleAllowed = sender.isOn
        if !self.requestModel.ticketsSaleAllowed {
            self.requestModel.ticketURL = nil
        }
        
        let indexSet = IndexSet(integer: CreateEventSection.tickets.rawValue)
        self.tableView.reloadSections(indexSet, with: .automatic)
    }
    
    @objc private func publicByInviteSwitchToggled(_ sender: UISwitch) {
        self.requestModel.publicByInviteEvent = sender.isOn
        
        let indexPath = IndexPath(row: PrivateEventRow.toggle.rawValue,
                                  section: CreateEventSection.privateEvent.rawValue)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc private func privateSwitchToggled(_ sender: UISwitch) {
        self.requestModel.privateEvent = sender.isOn
        
        var indexSet = IndexSet(integer: CreateEventSection.privateEvent.rawValue)
        indexSet.insert(CreateEventSection.publicByInviteOptions.rawValue)
        self.tableView.reloadSections(indexSet, with: .automatic)
    }
    
    @objc private func limitedSpaceEventSwitchToggled(_ sender: UISwitch) {
        self.requestModel.limitedSpaces = sender.isOn
        if !self.requestModel.limitedSpaces {
            self.requestModel.guestCap = InvalidDefaultValue
        }
        
        let indexSet = IndexSet(integer: CreateEventSection.limitedSpace.rawValue)
        self.tableView.reloadSections(indexSet, with: .automatic)
    }
    
    @objc private func forwardingSwitchToggled(_ sender: UISwitch) {
        self.requestModel.forwarding = sender.isOn
    }

    @objc private func chatSwitchToggled(_ sender: UISwitch) {
        self.requestModel.allowChat = sender.isOn
    }
    
    @objc private func timelineSwitchToggled(_ sender: UISwitch) {
        self.requestModel.showTimeline = sender.isOn
    }
    
    @objc private func contributionsEnabledSwitchToggled(_ sender: UISwitch) {
        let indexSet = IndexSet(integer: CreateEventSection.contributions.rawValue)

        if sender.isOn {
            sender.isOn = false
            VerificationListViewController.verifyUser(from: self) { [unowned self] user in
                sender.setOn(true, animated: true)
                self.user = user
                self.requestModel.contributionsEnabled = true
                self.requestModel.contribution = ContributionRequestModel()
                self.tableView.reloadSections(indexSet, with: .automatic)
            }

        } else {
            self.requestModel.contributionsEnabled = false
            self.requestModel.contribution = nil
            self.tableView.reloadSections(indexSet, with: .automatic)
        }
    }
    
    @objc private func optionalContributionSwitchToggled(_ sender: UISwitch) {
        self.requestModel.contribution?.optional = sender.isOn
    }
    
    // MARK: - Networking
    
    public func handleMediaUpload(withHandler completionHandler: @escaping (Error?) -> Void) {
        
        if let videoUrl = self.selectedVideoUrl {
            self.showSpinner(withTitle: "ADD_EVENT_CONVERT_MEDIA".localized)
            
            SHOS3Utils.encodeVideo(videoUrl) { (url, error) in
                self.dismissSpinner()
                
                if let error = error {
                    completionHandler(error)
                }
                else if let mp4url = url {
                    self.performUpload(ofVideoWithUrl: mp4url, withHandler: completionHandler)
                }
            }
            
        } else if let image = self.selectedImage {
            self.performUpload(of: image, withHandler: completionHandler)
            
        } else if self.requestModel.mediaItems.count == 0 {
            let userInfo = [NSLocalizedDescriptionKey: "ADD_EVENT_NO_MEDIA".localized]
            let error = NSError(domain: Constants.errorDomain, code: NSURLErrorFileDoesNotExist, userInfo: userInfo)
            completionHandler(error)
        }
        else {
            completionHandler(nil)
        }
    }
    
    private func performUpload(of image: UIImage, withHandler completionHandler: @escaping (Error?) -> Void) {
        
        self.showSpinner(withTitle: "ADD_EVENT_UPLOADING_MEDIA".localized)
        
        SHOS3Utils.upload(image, configuration: .eventMedia()) { imageUrl, error in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let url = imageUrl {
                let mediaItem = MediaRequestModel(type: .image, url: url)
                
                self.requestModel.mediaItems.removeAll()
                
                self.requestModel.mediaItems.append(mediaItem)
            }
            
            completionHandler(error)
        }
    }
    
    private func performUpload(ofVideoWithUrl url: URL, withHandler completionHandler: @escaping (Error?) -> Void) {
        
        self.showSpinner(withTitle: "ADD_EVENT_UPLOADING_MEDIA".localized)
        
        SHOS3Utils.uploadFile(withUrl: url, contentType: "video/mp4", configuration: .eventMedia()) { videoUrl, error in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let url = videoUrl {
                let mediaItem = MediaRequestModel(type: .video, url: url)
                self.requestModel.mediaItems.append(mediaItem)
            }
            
            completionHandler(error)
        }
    }
    
    private func createEvent() {
        self.showSpinner()
        SHOAPIClient.shared.createEvent(with: self.requestModel) { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.createdEvent = object as? EventModel
                if let event = self.createdEvent {
                    self.calendarManager.handleEvent(event, forUser: self.user, completion: { [unowned self] in
                        self.navigateToSelectInvitees()
                    })
                } else {
                    self.navigateToSelectInvitees()
                }
            }
        }
    }
    
    private func navigateToSelectInvitees() {
        self.navigationController?.dismiss(animated: true, completion: {
            
            if let eventId = self.createdEvent?.eventId,
                let tabBar = AppDelegate.shared?.window?.rootViewController as? UITabBarController {
                
                let controller = SelectEventInviteesViewController(with: eventId)
                let navController = UINavigationController(rootViewController: controller)
                tabBar.present(navController, animated: true)
            }
        })
    }

    //MARK: - UITableView Datasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return CreateEventSection.SECTIONS_COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch CreateEventSection(rawValue: section) {
        case .details?:
            return EventDetailsRow.ROW_COUNT.rawValue
        case .tickets?:
            return self.requestModel.ticketsSaleAllowed ? SellTicketsRow.ROW_COUNT.rawValue : 1
        case .publicByInviteOptions?:
            return PublicByInviteRow.ROW_COUNT.rawValue
        case .privateEvent?:
            return PrivateEventRow.ROW_COUNT.rawValue
        case .limitedSpace?:
            return self.requestModel.limitedSpaces ? LimitedSpaceRow.ROW_COUNT.rawValue : 1
        case .actions?:
            return ActionsRow.ROW_COUNT.rawValue
        case .contributions?:
            return self.requestModel.contributionsEnabled ? ContributionsRow.ROW_COUNT.rawValue : 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CreateEventSection(rawValue: indexPath.section) {
        case .details?:
            return self.tableView(tableView, detailsCellForRowAt: indexPath)
            
        case .location?:
            return self.tableView(tableView, locationCellForRowAt: indexPath)
            
        case .tickets?:
            return self.tableView(tableView, ticketCellForRowAt: indexPath)
            
        case .categories?:
            return self.tableView(tableView, categoriesCellForRowAt: indexPath)
            
        case .publicByInviteOptions?:
            return self.tableView(tableView, publicByInviteCellForRowAt: indexPath)
            
        case .privateEvent?:
            return self.tableView(tableView, privateEventCellForRowAt: indexPath)
            
        case .limitedSpace?:
            return self.tableView(tableView, limitedSpaceForRowAt: indexPath)
            
        case .actions?:
            return self.tableView(tableView, actionsCellForRowAt: indexPath)
            
        case .contributions?:
            return self.tableView(tableView, contributionsCellForRowAt: indexPath)
            
        case .bring?:
            return self.tableView(tableView, bringCellForRowAt: indexPath)
            
        default:
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
    }
    
    //MARK: Helpers
    
    func tableView(_ tableView: UITableView, detailsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = EventDetailsRow(rawValue: indexPath.row) else {
            assertionFailure("No cell returned from datasource")
            return UITableViewCell()
        }
        
        switch rowType {
            
        case .title:
            let cell: TextFieldTableViewCell = configuredTextFieldCell(for: tableView)
            cell.imageView?.image = rowType.image
            
            cell.textField.placeholder = rowType.title
            cell.textField.text = self.requestModel.title
            cell.textHandler = { [unowned self] text in
                self.requestModel.title = text
            }
            return cell
            
        case .description:
            let cell: TextViewTableViewCell = TextViewTableViewCell.reusableCell(
                from: tableView,
                reuseId: DescriptionCellReuseIdentifier,
                initialConfig: { (cell) in
                    cell.separatorView.isHidden = true
                    cell.textView.font = Font.regular.withSize(.large)
                    cell.iconImageView.image = rowType.image
                    cell.textView.placeholder = rowType.title
            })
            
            cell.textView.text = self.requestModel.description
            
            cell.textHandler = { [unowned self] text in
                self.requestModel.description = text
            }
            
            cell.textViewSizeChangeHandler = { [unowned tableView] textView in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            return cell
            
        case .time, .date:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.imageView?.image = rowType.image
            cell.label.text = rowType.title
            cell.separatorView.isHidden = true
            
            let mode: UIDatePickerMode = rowType == .time ? .time : .date
            let pickerSheet = DatePickerSheet(with: mode, responder: cell.textField)
            pickerSheet.picker.minuteInterval = 5
            cell.textField.inputView = pickerSheet
            
            if mode == .date {
                pickerSheet.picker.minimumDate = Date()
            }
            
            switch rowType {
            case .time:
                if let time = self.requestModel.time {
                    let dateObject = Date(timeIntervalSince1970: time)
                    pickerSheet.picker.setDate(dateObject, animated: true)
                    cell.textField.text = dateObject.string(withFormat: .time)
                }
            case .date:
                if let date = self.requestModel.date {
                    let dateObject = Date(timeIntervalSince1970: date)
                    pickerSheet.picker.setDate(dateObject, animated: true)
                    cell.textField.text = dateObject.string(withFormat: .short)
                }
            default:
                break
            }
            
            pickerSheet.selectionHandler = { [unowned self, unowned cell] date in
                if let date = date {
                    pickerSheet.picker.setDate(date, animated: true)
                    
                    switch rowType {
                    case .time:
                        cell.textField.text = date.string(withFormat: .time)
                        self.requestModel.time = date.timeIntervalSince1970
                    case .date:
                        cell.textField.text = date.string(withFormat: .short)
                        self.requestModel.date = date.timeIntervalSince1970
                    default:
                        break
                    }
                }
            }
            
            return cell
            
        case .adultOnly:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            cell.textLabel?.text = rowType.title
            cell.imageView?.image = rowType.image
            
            let aSwitch = UISwitch()
            aSwitch.onTintColor = .green
            aSwitch.isOn = requestModel.eighteenPlus
            aSwitch.addTarget(self, action: #selector(adultOnlySwitchToggled), for: .valueChanged)
            cell.accessoryView = aSwitch
            
            return cell
            
        default:
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, locationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        cell.imageView?.image = .location
        cell.textLabel?.text = self.requestModel.eventAddress ?? "EVENT_LOCATION".localized
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, ticketCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = SellTicketsRow(rawValue: indexPath.row) else {
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
        
        switch rowType {
        case .enable:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            cell.textLabel?.text = rowType.title
            cell.imageView?.image = rowType.image
            
            let aSwitch = UISwitch()
            aSwitch.onTintColor = .green
            aSwitch.isOn = requestModel.ticketsSaleAllowed
            aSwitch.addTarget(self, action: #selector(ticketSaleSwitchToggled), for: .valueChanged)
            cell.accessoryView = aSwitch
            
            return cell
        case .link:
            let cell: TextFieldTableViewCell = configuredTextFieldCell(for: tableView)
            cell.imageView?.image = rowType.image
            
            cell.textField.placeholder = rowType.title
            cell.textField.text = self.requestModel.ticketURL
            cell.textField.keyboardType = .URL
            cell.textField.autocapitalizationType = .none
            cell.textHandler = { [unowned self] text in
                self.requestModel.ticketURL = text
            }
            return cell
        case .description:
            let cell: TextViewTableViewCell = self.configuredDescriptionCell(for: tableView)
            cell.textView.text = rowType.title
            return cell
        default:
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, categoriesCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MentionsTextViewTableViewCell = MentionsTextViewTableViewCell.reusableCell(from: tableView) { cell in
            cell.separatorView.isHidden = true
        }
        
        cell.textView.placeholder = "EVENT_CATEGORIES".localized
        cell.textView.text = self.requestModel.categories
        cell.iconImageView.image = .hashTag
        
        cell.textViewSizeChangeHandler = { [unowned tableView] textView in
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        cell.textHandler = { [unowned self] text in
            //Remove any words without '#' prefix
            let filteredTags = text.split(separator: " ").filter({ $0.first == "#" })
            let tagsString = filteredTags.joined(separator: " ")
            self.requestModel.categories = tagsString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, inviteFriendsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(
            from: tableView,
            withStyle: .value1,
            reuseId: FriendsCellReuseIdentifier,
            initialConfig: { (cell) in
                cell.separatorView.isHidden = true
                cell.selectionStyle = .default
                cell.imageView?.image = .eventFriends
                cell.textLabel?.text = "OPTIONS_INVITE_FRIENDS".localized
                cell.detailTextLabel?.textColor = .text
                cell.accessoryType = .disclosureIndicator
        })
        
        let invitedCount = self.requestModel.attendees.count
        if invitedCount > 0 {
            cell.detailTextLabel?.text = String(format: "OPTIONS_FRIENDS_COUNT".localized, invitedCount)
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        if self.requestModel.inviteAllFriends {
            cell.detailTextLabel?.text = "OPTIONS_FRIENDS_ALL".localized
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, publicByInviteCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = PublicByInviteRow(rawValue: indexPath.row)
        
        switch row {
        case .publicByInvite?:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            
            cell.textLabel?.text = row?.title
            cell.imageView?.image = row?.image
            
            let aSwitch = UISwitch()
            aSwitch.onTintColor = .green
            cell.accessoryView = aSwitch
            aSwitch.isOn = self.requestModel.publicByInviteEvent
            aSwitch.addTarget(self, action: #selector(publicByInviteSwitchToggled), for: .valueChanged)
            aSwitch.isEnabled = !self.requestModel.privateEvent
            
            return cell
            
        case .description?:
            let cell: TextViewTableViewCell = self.configuredDescriptionCell(for: tableView)
            cell.textView.text = row?.title
            return cell
            
        default:
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, privateEventCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = PrivateEventRow(rawValue: indexPath.row)?.title
        let image = PrivateEventRow(rawValue: indexPath.row)?.image
        
        switch PrivateEventRow(rawValue: indexPath.row) {
        case .toggle?:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            cell.textLabel?.text = text
            cell.imageView?.image = image
            
            let aSwitch = UISwitch()
            aSwitch.isOn = self.requestModel.privateEvent
            aSwitch.onTintColor = .green
            aSwitch.addTarget(self, action: #selector(privateSwitchToggled), for: .valueChanged)
            cell.accessoryView = aSwitch
            aSwitch.isEnabled = !self.requestModel.publicByInviteEvent
            
            return cell
            
        case .description?:
            let cell: TextViewTableViewCell = self.configuredDescriptionCell(for: tableView)
            cell.textView.text = text
            return cell
            
        default:
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, limitedSpaceForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row =  LimitedSpaceRow(rawValue: indexPath.row)
        
        switch row {
        case .limitedSpaces?:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            cell.textLabel?.text = row?.title
            cell.imageView?.image = row?.image
            
            let aSwitch = UISwitch()
            aSwitch.onTintColor = .green
            cell.accessoryView = aSwitch
            aSwitch.isOn = self.requestModel.limitedSpaces
            aSwitch.addTarget(self, action: #selector(limitedSpaceEventSwitchToggled), for: .valueChanged)
            
            return cell
        case .guestCap?:
            let cell: TextFieldTableViewCell = configuredTextFieldCell(for: tableView)
            
            cell.label.text = row?.title
            cell.imageView?.image = row?.image
            cell.textField.placeholder = "OPTIONS_LIMITED_SPACE_PLACEHOLDER".localized
            cell.textField.keyboardType = .numberPad
            
            if self.requestModel.guestCap != InvalidDefaultValue {
                cell.textField.text = "\(self.requestModel.guestCap)"
            }
            else {
                cell.textField.text = nil
            }
            
            cell.textHandler = { [unowned self] text in
                if let maxAttendees = text.toNumber()?.intValue {
                    self.requestModel.guestCap = maxAttendees
                }
                else {
                    self.requestModel.guestCap = InvalidDefaultValue
                }
            }
            
            return cell
            
        default:
            return SHOTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, actionsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
        
        let row =  ActionsRow(rawValue: indexPath.row)
        
        cell.textLabel?.text = row?.title
        cell.imageView?.image = row?.image
        
        let aSwitch = UISwitch()
        aSwitch.onTintColor = .green
        cell.accessoryView = aSwitch
        
        switch row {
        case .forwarding?:
            aSwitch.isOn = self.requestModel.forwarding
            aSwitch.addTarget(self, action: #selector(forwardingSwitchToggled), for: .valueChanged)
            
        case .chatEnabled?:
            aSwitch.isOn = self.requestModel.allowChat
            aSwitch.addTarget(self, action: #selector(chatSwitchToggled), for: .valueChanged)
            
        case .timelineEnabled?:
            aSwitch.isOn = self.requestModel.showTimeline
            aSwitch.addTarget(self, action: #selector(timelineSwitchToggled), for: .valueChanged)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contributionsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = ContributionsRow(rawValue: indexPath.row)?.title
        let image = ContributionsRow(rawValue: indexPath.row)?.image
        
        switch ContributionsRow(rawValue: indexPath.row) {
        case .enabled?:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            cell.textLabel?.text = title
            cell.imageView?.image = image
            
            let aSwitch = UISwitch()
            aSwitch.onTintColor = .green
            aSwitch.isOn = self.requestModel.contributionsEnabled
            aSwitch.addTarget(self, action: #selector(contributionsEnabledSwitchToggled), for: .valueChanged)
            cell.accessoryView = aSwitch
            
            return cell
            
        case .amount?:
            let cell: TextFieldTableViewCell = configuredTextFieldCell(for: tableView)
            cell.label.text = title
            cell.imageView?.image = image
            
            let currencySymbol = self.user?.countryOfResidence?.currency.symbol ?? String()
            
            cell.textField.keyboardType = .numberPad
            cell.textField.placeholder = "\(currencySymbol)0"
            
            if let contribution = self.requestModel.contribution,
                contribution.amountCents > 0 {
                cell.textField.text = "\(currencySymbol)\(contribution.amountCents / 100)"
            } else {
                cell.textField.text = nil
            }
            
            cell.textHandler = { [unowned self, unowned cell] text in
                var text = text
                
                if let first = text.first,
                    String(first) == currencySymbol {
                    text.removeFirst()
                }
                
                if let amountInput = Int(text) {
                    self.requestModel.contribution?.amountCents = amountInput * 100
                } else {
                    self.requestModel.contribution?.amountCents = 0
                }
                
                if text.count > 0 {
                    cell.textField.text = "\(currencySymbol)\(text)"
                } else {
                    cell.textField.text = nil
                }
            }
            
            return cell
            
        case .reason?:
            let cell: TextFieldTableViewCell = configuredTextFieldCell(for: tableView)
            cell.imageView?.image = image
            
            cell.textField.placeholder = title
            cell.textField.text = self.requestModel.contribution?.reason
            
            cell.textHandler = { [unowned self] text in
                self.requestModel.contribution?.reason = text
            }
            
            return cell
            
        case .optional?:
            let cell: SHOTableViewCell = configuredStandardCell(for: tableView)
            cell.textLabel?.text = title
            cell.imageView?.image = image
            
            let aSwitch = UISwitch()
            aSwitch.onTintColor = .green
            aSwitch.isOn = self.requestModel.contribution?.optional ?? false
            aSwitch.addTarget(self, action: #selector(optionalContributionSwitchToggled), for: .valueChanged)
            cell.accessoryView = aSwitch
            
            return cell
            
        default:
            assertionFailure("Blank cell returned from datasource")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, bringCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextFieldTableViewCell = configuredTextFieldCell(for: tableView)
        cell.imageView?.image = .bring
        
        cell.textField.placeholder = "EVENT_BRING".localized
        cell.textField.text = self.requestModel.bring
        
        cell.textHandler = { [unowned self] text in
            self.requestModel.bring = text
        }
        
        return cell
    }
    
    func configuredStandardCell(for tableView: UITableView) -> SHOTableViewCell {
        let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView) { cell in
            cell.separatorView.isHidden = true
        }
        cell.selectionStyle = .none
        cell.accessoryView = nil
        cell.accessoryType = .none
        return cell
    }
    
    func configuredTextFieldCell(for tableView: UITableView) -> TextFieldTableViewCell {
        let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView) { cell in
            cell.separatorView.isHidden = true
        }
        cell.textField.keyboardType = .default
        cell.textField.placeholder = nil
        cell.label.text = nil
        
        return cell
    }
    
    func configuredDescriptionCell(for tableView: UITableView) -> TextViewTableViewCell {
        let cell: TextViewTableViewCell = TextViewTableViewCell.reusableCell(
            from: tableView,
            reuseId: PublicByInviteDescriptionCellReuseIdentifier,
            initialConfig: { (cell) in
                cell.separatorView.isHidden = true
                cell.isUserInteractionEnabled = false
                cell.backgroundColor = .black10
                cell.textView.backgroundColor = .clear
                cell.textView.font = Font.regular.withSize(.small)
                cell.textView.textColor = .slateGrey
        })
        
        return cell
    }
}

//MARK: - AddEventHeaderViewDelegate

extension CreateEventViewController: AddEventHeaderViewDelegate {
    
    func didTapImageView(_ imageView: UIImageView) {
        
        self.headerView.videoPlayer.playbackFinished()
        
        self.imagePicker.openImageVideoActionSheet(withSelectionHandler: { [unowned self, unowned imageView] image, url, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                }
                self.selectedImage = image
                self.selectedVideoUrl = url
                self.headerView.videoPlayer.videoURL = url
                self.headerView.videoPlayer.isHidden = (url == nil)
                
                if let image = image {
                    imageView.image = image
                }
            }
        })
    }
    
}

//MARK: - UITableView Delegate

extension CreateEventViewController {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = CreateEventSection(rawValue: section)?.title {
            let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
            let headerView = SectionHeaderView(frame: frame)
            
            headerView.backgroundColor = .white
            headerView.leftLabel.text = title
            headerView.leftLabel.font = Font.regular.withSize(.medium)
            headerView.leftLabel.textColor = .green
            
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == CreateEventSection.privateEvent.rawValue ||
            section == CreateEventSection.actions.rawValue ||
            section == CreateEventSection.limitedSpace.rawValue {
            return 0
        }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch CreateEventSection(rawValue: indexPath.section) {
        case .location?:
            let controller = LocationPickerViewController(descriptionText: "EVENT_LOCATION_DESC".localized)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)

        default:
            break
        }
    }
    
}

extension CreateEventViewController: LocationPickerViewControllerDelegate {
    
    func didSelectLocation(withCoordinate coordinate: CLLocationCoordinate2D, displayName: String) {
        self.requestModel.latitude = coordinate.latitude
        self.requestModel.longitude = coordinate.longitude
        self.requestModel.eventAddress = displayName
        
        let indexSet = IndexSet(integer: CreateEventSection.location.rawValue)
        self.tableView.reloadSections(indexSet, with: .automatic)
    }
    
}

extension CreateEventViewController: VideoPlayerViewDelegate {
    func didTapMediaSelectionButton() {
        self.headerView.videoPlayer.playbackFinished()
        self.didTapImageView(self.headerView.imageView)
    }
}
