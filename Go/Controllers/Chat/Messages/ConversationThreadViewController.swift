//
//  BaseMessagesViewController.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import MessageKit
import SKPhotoBrowser
import AVKit
import MapKit
import GoogleMaps
import StaticMapRequestBuilder

private let IncomingBubbleColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
private let IncomingTextColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
private let OutgoingBubbleColor: UIColor = #colorLiteral(red: 0.1294117647, green: 0.8156862745, blue: 0.7490196078, alpha: 1)
private let OutgoingTextColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
private let BackgroundImage: UIImage = UIImage.chatBackground
private let MediaCellHeight: CGFloat = 200.0
private let AvatarSize: CGSize = .zero
private let MapPinImage: UIImage = UIImage.chatLocationPin

class ConversationThreadViewController: MessagesViewController, CustomBackButton {
    
    var shouldPaginate: Bool = false
    
    var unsavedChanges: Bool {
        return self.messages.contains { (messageType) -> Bool in
            if let message = messageType as? Message {
                return message.status == .failed
            }
            
            return false
        }
    }
    
    lazy var reachability: Reachability? = {
        let reach = Reachability()
        
        reach?.whenReachable = { [weak self] (reachability) in
            self?.changeInputBarStatus(enable: true)
        }
        
        reach?.whenUnreachable = { [weak self] (reachability) in
            self?.changeInputBarStatus(enable: false)
        }
        
        return reach
    }()
    
    var messages: [MessageType] = []
    
    lazy var imagePicker: SHOImagePickerUtils = {
        let picker = SHOImagePickerUtils(with: self)
        picker.imageVideoSelectionHandler = { [weak self] (image, url, error) in
            if let error = error {
                self?.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                if let videoURL = url {
                    self?.encodeVideo(withUrl: videoURL) { [weak self] (videoS3URLStr) in
                        if let S3URLStr = videoS3URLStr,
                            let finalURL = URL(string: S3URLStr) {
                            
                            let videoAttachment = VideoAttachment(videoURL: finalURL)
                            let attachment = Attachment(videoAttachment: videoAttachment)
                            self?.createAndSendMessage(with: [attachment])
                        }
                    }
                }
                else if let image = image {
                    self?.upload(image: image) { [weak self] (imageS3URLStr) in
                        if let S3URLStr = imageS3URLStr,
                            let finalURL = URL(string: S3URLStr) {
                            
                            let imageAttachment = ImageAttachment(imageURL: finalURL)
                            let attachment = Attachment(imageAttachment: imageAttachment)
                            self?.createAndSendMessage(with: [attachment])
                        }
                    }
                }
                
            }
        }
        return picker
    }()
    
    var backgroundImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = BackgroundImage
        return imageView
    }()
    
    lazy var moreButton: UIBarButtonItem = UIBarButtonItem(image: .actionButton,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(moreButtonPressed))
    
    var user: UserModel?
    var shouldRefreshConversation: Bool = false
    var conversation: Conversation! {
        didSet {
            self.configureTitle()
        }
    }
    
    // MARK: - Inits
    
    convenience init(conversation: Conversation) {
        self.init(nibName: nil, bundle: nil)
        
        self.conversation = conversation
        self.shouldRefreshConversation = false
    }
    
    convenience init?(conversationID: Int64) {
        if let aConversation = try? Conversation(object: ["id": conversationID]) {
            self.init(conversation: aConversation)
            self.shouldRefreshConversation = true
        }
        else {
            return nil
        }
    }
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInputBar()
        
        self.scrollsToBottomOnKeybordBeginsEditing = true
        self.maintainPositionOnKeyboardFrameChanged = true
        
        self.messagesCollectionView.register(DailyMessageHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messagesCollectionView.messageCellDelegate = self
        
        if self.shouldRefreshConversation {
            self.loadConversation()
        }
        else {
            self.loadMessages()
        }
        
        // background image
        self.messagesCollectionView.backgroundView = self.backgroundImageView
        
        self.setupBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? self.reachability?.startNotifier()
        
        CacheManager.getCurrentUser(withFallbackPolicy: .network(controller: self)) { (user, error) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.user = user
            }
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.reachability?.stopNotifier()
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - User Actions
    
    @objc func backButtonIntercept() {
        if self.unsavedChanges {
            self.showUnsavedChangesWarning("UNSENT_MESSAGE_MSG".localized)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func moreButtonPressed() {
        
        var alertAction: UIAlertAction
        
        if self.conversation.muted {
            alertAction = UIAlertAction(title: "UNMUTE_CONVERSATION_TITLE".localized,
                                        style: .default) { [weak self] (action) in
                                            self?.unmuteConversation()
            }
        }
        else {
            alertAction = UIAlertAction(title: "MUTE_CONVERSATION_TITLE".localized,
                                        style: .default) { [weak self] (action) in
                                            self?.muteConversation()
            }
        }
        
        let deleteAction = UIAlertAction(title: "DELETE_CONVERSATION_TITLE".localized,
                                         style: .destructive) { [weak self] (action) in
                                            self?.deleteConversation()
        }
        
        var participantsTitle = "CONVERSATION_VIEW_PARTICIPANTS".localized
        if self.conversation.owner {
            participantsTitle = "CONVERSATION_EDIT_PARTICIPANTS".localized
        }
        
        let participantsAction = UIAlertAction(title: participantsTitle,
                                               style: .default) { [unowned self] (action) in
                                                let controller = ChatParticipantsViewController(conversation: self.conversation)
                                                self.navigationController?.pushViewController(controller, animated: true)
        }
        
        let cancelAction = SHOViewController.cancelAction()
        
        //Don't allow viewing/editing of participants for event chats
        var actions = [alertAction, deleteAction, cancelAction]
        if self.conversation.event == nil {
            actions.insert(participantsAction, at: 2)
        }
        
        if let actionSheet = SHOViewController.actionSheetWith(title: "CONVERSATION_OPTIONS_TITLE".localized,
                                                            message: "CONVERSATION_OPTIONS_MESSAGE".localized,
                                                            actions: actions) {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func navigateToLocation(location: CLLocation, name: String = "") {
        let coordinate = location.coordinate
        let urlString = String(format: Constants.googleMapsDirectionsURL,
                               coordinate.latitude,
                               coordinate.longitude)
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func manageSelection(message: MessageType, at index: Int) {
        switch message.data {
            
        case .location(let location):
            self.navigateToLocation(location: location, name: message.sender.displayName)
        
        case .photo(let image):
            guard let message = message as? Message else { return }
            var images = [SKPhoto]()
            
            if let imageURL = message.attachments.first?.imageAttachment?.images.largeUrl {
                let photo = SKPhoto.photoWithImageURL(imageURL)
                photo.shouldCachePhotoURLImage = true
                images.append(photo)
            }
            else {
                let photo = SKPhoto.photoWithImage(image)
                images.append(photo)
            }
            
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            self.present(browser, animated: true, completion: {})
            
        
        case .video(let videoUrl, _):
            let videoPlayerController = AVPlayerViewController.configured(with: videoUrl)
            self.present(videoPlayerController, animated: true) {
                videoPlayerController.player?.play()
            }
            
        default:
            print("Message cell tapped")
        }
    }
    
    func manageFailedMessageSelection(message: MessageType, at index: Int) {
        UIAlertController.showFailedMessageOptions(on: self) { [weak self] (selectedOption) in
            switch selectedOption {
                
            case .resend:
                self?.send(message: message, at: index)
            
            case .delete:
                self?.messages.remove(at: index)
                self?.messagesCollectionView.deleteSections([index])
            }
            
        }
    }
    
    @objc func chatTitleTapped() {
        if let event = self.conversation.event {
            self.navigationController?.pushViewController(EventViewController(withId: event.eventId), animated: true)
        }
    }
}

// MARK: - MessagesDataSource -

extension ConversationThreadViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        if let user = self.user {
            return Sender(id: "\(user.userId)", displayName: user.displayName)
        }
        
        return Sender(id: "0", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messages[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            return nil
        }
        
        return NSAttributedString(string: message.sender.displayName,
                                  attributes: [.foregroundColor: OutgoingBubbleColor,
                                               .font: UIFont.systemFont(ofSize: 13.0)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = (message.sentDate.string(withFormat: DateFormat.time) ?? "") + " "
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        let label = NSMutableAttributedString(string: date, attributes: [.font: font])
        
        return label
    }
    
}

// MARK: - MessagesLayoutDelegate -

extension ConversationThreadViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType,
                    at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return AvatarSize
    }
    
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return MediaCellHeight
    }
    
    func heightForMedia(message: MessageType,
                        at indexPath: IndexPath,
                        with maxWidth: CGFloat,
                        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return MediaCellHeight
    }
    
    func cellTopLabelAlignment(for message: MessageType,
                               at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        return .cellLeading(UIEdgeInsetsMake(0, 15, 0, 0))
    }
    
    func cellBottomLabelAlignment(for message: MessageType,
                                  at indexPath: IndexPath,
                                  in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        return self.isFromCurrentSender(message: message) ? .cellTrailing(UIEdgeInsetsMake(0, 0, 0, 23)) :
            .cellLeading(UIEdgeInsetsMake(0, 23, 0, 0))
    }
    
}

// MARK: - MessagesDisplayDelegate -

extension ConversationThreadViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        if indexPath.section == 1 && self.shouldPaginate {
            self.loadMessages()
        }
        
        switch message.data {
        case .photo:
            
            let configurationClosure = { [unowned self] (containerView: UIImageView) in
                let imageMask = UIImageView()
                let corner: MessageStyle.TailCorner = self.isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
                imageMask.image = MessageStyle.bubbleTail(corner, .curved).image
                imageMask.frame = containerView.bounds
                containerView.mask = imageMask
                containerView.contentMode = .scaleAspectFill
                
                containerView.kf.indicatorType = .activity
                
                guard
                    let message = message as? Message,
                    let attachment = message.attachments.first?.imageAttachment,
                    let urlString = attachment.images.largeUrl,
                    let url = URL(string: urlString)
                else {
                        print("Could not convert message into a readable Message format")
                        return
                }
                
                containerView.kf.setImage(with: url, placeholder: UIImage.mediaPlaceholder) { (image, error, cache, url) in
                    
                    if let error = error {
                        containerView.image = .mediaPlaceholder
                        print(error.localizedDescription)
                    } else if let image = image {
                        containerView.image = image
                    }
            
                }
            }
            return .custom(configurationClosure)
            
        case .video:
            
            let configurationClosure = { [unowned self] (containerView: UIImageView) in
                let imageMask = UIImageView()
                let corner: MessageStyle.TailCorner = self.isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
                imageMask.image = MessageStyle.bubbleTail(corner, .curved).image
                imageMask.frame = containerView.bounds
                containerView.mask = imageMask
                containerView.contentMode = .scaleAspectFill
                
                containerView.kf.indicatorType = .activity
                
                guard
                    let message = message as? Message,
                    let video = message.attachments.first?.videoAttachment,
                    let thumbnailURL = URL(string: video.images?.mediumUrl ?? "")
                else {
                        print("Could not convert message into a readable Message format")
                        return
                }
                
                containerView.kf.setImage(with: thumbnailURL) { (image, error, cache, url) in
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            containerView.image = .mediaPlaceholder
                            print(error.localizedDescription)
                        } else if let image = image {
                            containerView.image = image
                        }
                    }
                }
            }
            return .custom(configurationClosure)
            
        default:
            let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            return .bubbleTail(corner, .curved)
        }
        
    }
    
    // MARK: Chat Header
    
    func messageHeaderView(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageHeaderView {
        let header = messagesCollectionView.dequeueReusableHeaderView(DailyMessageHeaderView.self, for: indexPath)
        header.dateLabel.text = message.sentDate.relativeDaily()
        return header
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        if indexPath.section == 0 { return true }
        let previousSection = indexPath.section - 1
        let previousMessage = self.messages[previousSection]
        let currentMessageDay = message.sentDate.day
        let previousMessageDay = previousMessage.sentDate.day
        return (currentMessageDay != previousMessageDay)
    }
    
    func headerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        let shouldDisplay = self.shouldDisplayHeader(for: message, at: indexPath, in: messagesCollectionView)
        return shouldDisplay ? CGSize(width: messagesCollectionView.bounds.width, height: 20) : .zero
    }
    
    // MARK: Text Messages
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? OutgoingTextColor : IncomingTextColor
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return self.isFromCurrentSender(message: message) ? OutgoingBubbleColor : IncomingBubbleColor
    }
    
    // MARK: Location Messages

    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        
        guard case .location(let location) = message.data else {
            return nil
        }

        let coordinate = location.coordinate
        let apiKey = AppDelegate.shared?.googleMapsAPIKey
        
        return { imageView in
            if
                let key = apiKey,
                let mapUrl = MapRequestBuilder(withSize: imageView.frame.size)
                        .addCenter(.coordinate(coordinate))
                        .addZoom(12)
                        .mapType(.roadmap)
                        .imageFormat(.png)
                        .retinaScale()
                        .addMarker(Marker(coordinate: coordinate))
                        .apiKey(key)
                        .build() {
                imageView.kf.setImage(with: mapUrl)
            }
        }
    }
    
}

// MARK: - MessageCellDelegate -

extension ConversationThreadViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = self.messagesCollectionView.indexPath(for: cell) {
            let message = self.messages[indexPath.section]
            
            let messageObj = message as? Message
            let status = messageObj?.status
            
            if status == .failed {
                self.manageFailedMessageSelection(message: message, at: indexPath.section)
            }
            else {
                self.manageSelection(message: message, at: indexPath.section)
            }
        }
    }
    
    func didTapTopLabel(in cell: MessageCollectionViewCell) {
        if let indexPath = self.messagesCollectionView.indexPath(for: cell),
            let message = self.messages[indexPath.section] as? Message {
            
            let controller = UserProfileViewController.controllerForUserWithId(userId: message.owner.id)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

// MARK: - MessageLabelDelegate -

extension ConversationThreadViewController: MessageLabelDelegate {
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        let action = "tel:" + phoneNumber
        self.handleAction(action: action)
    }
    
    func didSelectURL(_ url: URL) {
        self.handleAction(action: url.absoluteString)
    }
    
    private func handleAction(action: String) {
        if let actionURL = URL(string: action), UIApplication.shared.canOpenURL(actionURL) {
            UIApplication.shared.open(actionURL)
        }
    }
    
}

// MARK: - MessageInputBar -

extension ConversationThreadViewController {
    
    func setupInputBar() {
        let inputBar = GoMessageInputBar()
        inputBar.customDelegate = self
        
        // text view
        inputBar.inputTextView.placeholder = ""
        inputBar.inputTextView.layer.cornerRadius = 15
        inputBar.inputTextView.layer.borderWidth = 0.5
        inputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        
        // right stack view
        inputBar.setRightStackViewWidthConstant(to: 30, animated: true)
        inputBar.setStackViewItems([inputBar.sendInputBarButtonItem], forStack: .right, animated: true)
        
        // left stack view
        inputBar.setLeftStackViewWidthConstant(to: 30, animated: true)
        inputBar.setStackViewItems([inputBar.attachmentInputBarButtonItem], forStack: .left, animated: true)
        
        self.messageInputBar = inputBar
        
        reloadInputViews()
    }
    
}

// MARK: - MessageInputBarDelegate -

extension ConversationThreadViewController: GoMessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: GoMessageInputBar,
                         didPressSendButton button: InputBarButtonItem,
                         with text: String) {
        if !text.isEmpty {
            inputBar.clearText()
            self.createAndSendMessage(with: [], text: text)
        }
    }
    
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressAttachmentButton button: InputBarButtonItem) {
        
        inputBar.resignKeyboard(clearText: true)
        
        UIAlertController.showChatAttachmentOptions(on: self) { [weak self] (selectedOption) in
            switch selectedOption {
            case .location:
                let locationVC = LocationPickerViewController(descriptionText: "SELECT_LOCATION_TITLE".localized)
                locationVC.delegate = self
                self?.navigationController?.pushViewController(locationVC, animated: true)
            case .photo:
                self?.imagePicker.showPhotoLibrary(allowVideo: true)
            case .camera:
                self?.imagePicker.showCamera(allowVideo: true)
            }
        }
    }
}

extension ConversationThreadViewController: LocationPickerViewControllerDelegate {
    
    
    // MARK: - LocationPickerViewControllerDelegate
    
    func didSelectLocation(withCoordinate coordinate: CLLocationCoordinate2D, displayName: String) {
        let locationAttachment = LocationAttachment(latitude: coordinate.latitude,
                                                    longitude: coordinate.longitude)
        
        let attachment = Attachment(locationAttachment: locationAttachment)
        
        self.createAndSendMessage(with: [attachment])
    }
    
    // MARK: - Helper Methods
    
    func setupBarButtons() {
        let button = UIBarButtonItem(image: .backButton,
                                     style: .plain,
                                     target: self,
                                     action: #selector(backButtonIntercept))
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = button
        self.navigationItem.rightBarButtonItem = self.moreButton
        
        self.configureTitle()
    }
    
    func configureTitle() {
        let config = LabelConfig(textFont: Font.semibold.withSize(.medium),
                                 textAlignment: .center,
                                 textColor: .darkText,
                                 backgroundColor: .clear,
                                 numberOfLines: 2)
        let titleLabel = UILabel(with: config)
        
        let title = NSMutableAttributedString(string: "CHAT_TITLE_INITIAL".localized)
        title.append(self.conversation.name.attributedString(with: [.font: Font.regular.withSize(.extraSmall)]))
        titleLabel.attributedText = title
        
        if self.conversation.event != nil {
            titleLabel.textColor = UIColor.green
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chatTitleTapped))
            gestureRecognizer.numberOfTapsRequired = 1
            titleLabel.addGestureRecognizer(gestureRecognizer)
            titleLabel.isUserInteractionEnabled = true
        }
        
        self.navigationItem.titleView = titleLabel
        self.navigationItem.titleView?.frame.size.height = 30
    }
    
    func messageOwner() -> Participant? {
        return self.conversation.participants.first(where: {$0.id == self.user?.userId})
    }
    
    func createAndSendMessage(with attachments: [Attachment], text: String = "") {
        if let owner = self.messageOwner() {
            let message = Message(text: text, owner: owner, attachments: attachments)
            
            self.messages.append(message)
            self.messagesCollectionView.insertSections([self.messages.count - 1])
            self.messagesCollectionView.scrollToBottom()
            
            self.send(message: message, at: self.messages.indices.last ?? 0)
        }
    }
    
    func changeInputBarStatus(enable: Bool) {
        if let inputBar = self.messageInputBar as? GoMessageInputBar {
            inputBar.isUserInteractionEnabled = enable
            inputBar.sendInputBarButtonItem.isEnabled = enable
            inputBar.attachmentInputBarButtonItem.isEnabled = enable
            inputBar.inputTextView.backgroundColor = enable ? .white : .lightGray
        }
    }
}

// MARK: - Networking Methods

extension ConversationThreadViewController: SHOSpinner {
    
    var offset: Int {
        return self.messages.count
    }
    
    func loadMessages(fromOffset offset: Int? = nil) {
        SHOAPIClient.shared.messages(self.conversation.id, from: offset ?? self.offset) { (data, error, code) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                if let msgs = data as? [MessageType] {
                    var shouldScrollToBottom: Bool = (self.offset == 0)
                    
                    if offset == 0 {
                        self.messages.removeAll()
                        shouldScrollToBottom = true
                    }
                    
                    self.messages.append(contentsOf: msgs)
                    self.messages.sort(by: { $0.sentDate < $1.sentDate})
                    
                    self.messagesCollectionView.reloadData()
                    if shouldScrollToBottom {
                        self.messagesCollectionView.scrollToBottom(animated: false)
                        self.shouldPaginate = true
                    }
                    
                    self.shouldPaginate = (msgs.count > 0)

                    self.loadParticipants()
                }
            }
        }
    }
    
    func loadParticipants() {
        self.showSpinner()
        
        SHOAPIClient.shared.loadParticipants(withId: self.conversation.id) { (object, error, code) in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                if let participants = object as? [Participant] {
                    self.conversation.participants = participants
                }
            }
        }
    }
    
    func loadConversation() {
        self.showSpinner()
        
        SHOAPIClient.shared.conversation(id: self.conversation.id) { (data, error, code) in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                if let convo = data as? Conversation {
                    self.conversation = convo
                    self.loadMessages()
                }
            }
        }
    }
    
    func send(message: MessageType, at index: Int) {
        if let msg = message as? Message {
            SHOAPIClient.shared.send(msg, to: self.conversation) { (data, error, code) in
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                }
                else {
                    if let updatedMessage = data as? Message {
                        self.messages[index] = updatedMessage
                        self.messagesCollectionView.reloadSections([index])
                    }
                }
            }
        }
    }
    
    func muteConversation() {
        self.showSpinner()
        
        SHOAPIClient.shared.mute(self.conversation) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                self.conversation.muted = true
            }
        }
    }
    
    func unmuteConversation() {
        self.showSpinner()
        
        SHOAPIClient.shared.unmute(self.conversation) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                self.conversation.muted = false
            }
        }
    }
    
    func deleteConversation() {
        self.showSpinner()
        
        SHOAPIClient.shared.delete(self.conversation) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func upload(image: UIImage, completion: ((String?) -> Void)?) {
        self.showSpinner()
        
        SHOS3Utils.upload(image, configuration: .chatAttachment(userID: self.user?.userId)) { (imageURL, error) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            
            completion?(imageURL)
        }
    }
    
    private func encodeVideo(withUrl videoUrl: URL, completion: ((String?) -> Void)?) {
        self.showSpinner(withTitle: "ADD_EVENT_CONVERT_MEDIA".localized)
        
        SHOS3Utils.encodeVideo(videoUrl) { (url, error) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else if let mp4url = url {
                self.upload(videoURL: mp4url, completion: completion)
            }
        }
    }
    
    func upload(videoURL: URL, completion: ((String?) -> Void)?) {
        self.showSpinner()
        
        SHOS3Utils.uploadFile(withUrl: videoURL, contentType: "video/mp4", configuration: .chatAttachment(userID: self.user?.userId)) { (URLStr, error) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            
            completion?(URLStr)
        }
    }
}
