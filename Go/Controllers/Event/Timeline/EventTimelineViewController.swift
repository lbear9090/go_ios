//
//  EventTimelineViewController.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit
import MessageKit

class EventTimelineViewController: FeedViewController, SHOKeyboardNotifications, GoMessageInputBarDelegate, UITextViewDelegate {
    
    //MARK: - Properties
    
    var keyboardNotificationObservers: [NSObjectProtocol] = []
    private var bottomConstraint: Constraint?
    
    private let eventId: Int64
    private let eventTitle: String
    
    private lazy var imagePicker = SHOImagePickerUtils(with: self)
    private lazy var inputBar: GoMessageInputBar = {
        let inputBar: GoMessageInputBar = GoMessageInputBar.newAutoLayout()
        
        inputBar.customDelegate = self
        
        // text view
        inputBar.inputTextView.placeholder = ""
        inputBar.inputTextView.layer.cornerRadius = 15
        inputBar.inputTextView.layer.borderWidth = 0.5
        inputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        inputBar.inputTextView.delegate = self
        
        // right stack view
        inputBar.setRightStackViewWidthConstant(to: 30, animated: true)
        inputBar.setStackViewItems([inputBar.sendInputBarButtonItem], forStack: .right, animated: true)
        
        // left stack view
        inputBar.setLeftStackViewWidthConstant(to: 30, animated: true)
        inputBar.setStackViewItems([inputBar.attachmentInputBarButtonItem], forStack: .left, animated: true)
        
        return inputBar
    }()
    
    //MARK: - Init
    
    init(with dataProvider: FeedDataProvider, eventId: Int64, eventTitle: String) {
        self.eventId = eventId
        self.eventTitle = eventTitle
        super.init(with: dataProvider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTitle()
        self.collectionView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterForKeyboardNotifications()
    }
    
    func configureTitle() {
        let config = LabelConfig(textFont: Font.semibold.withSize(.medium),
                                 textAlignment: .center,
                                 textColor: .darkText,
                                 backgroundColor: .clear,
                                 numberOfLines: 2)
        let titleLabel = UILabel(with: config)
        
        let title = NSMutableAttributedString(string: "EVENT_TIMELINE_TITLE".localized)
        title.append(self.eventTitle.attributedString(with: [.font: Font.regular.withSize(.extraSmall)]))
                                                                            
        titleLabel.attributedText = title
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentEventController))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapRecognizer)
        
        self.navigationItem.titleView = titleLabel
        self.navigationItem.titleView?.frame.size.height = 30

    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.inputBar)
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        
        self.collectionView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }
        
        self.inputBar.snp.makeConstraints { make in
            bottomConstraint = make.bottom.equalToSuperview().constraint
            make.left.right.equalToSuperview()
            make.top.equalTo(self.collectionView.snp.bottom)
        }

    }
    
    //MARK: - Keyboard notifications
    
    func animateLayoutForKeyboard(frame: CGRect) {
        var height = frame.size.height
        
        if let tabController = self.tabBarController, height > 0 {
            height -= tabController.tabBar.bounds.height
        }
        
        self.bottomConstraint?.update(inset: height)
    }
    
    //MARK: - User actions
    
    @objc private func presentEventController() {
        let controller = EventViewController(withId: self.eventId)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func showTimeline(_ timeline: TimelineModel) {
        //Already showing timeline, so do nothing here
    }
    
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressSendButton button: InputBarButtonItem, with text: String) {
        if text.isEmpty {
            return
        }
        let request = MediaRequestModel(text: text)
        self.createTimelineItem(with: request)
    }
    
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressAttachmentButton button: InputBarButtonItem) {
        self.imagePicker.openImageVideoActionSheet(withSelectionHandler: { [unowned self] (image, videoUrl, error) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
                
            } else if let videoUrl = videoUrl {
                self.encodeVideo(withUrl: videoUrl)
                
            } else if let image = image {
                self.performUpload(of: image)
            }
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 140
    }
    
    //MARK: - Networking
    
    private func performUpload(of image: UIImage) {
        self.showSpinner()
        
        SHOS3Utils.upload(image, configuration: .timelineMedia(eventId: self.eventId)) { imageUrl, error in
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
                
            } else if let url = imageUrl {
                let request = MediaRequestModel(type: .image, url: url)
                self.createTimelineItem(with: request)
            }
        }
    }
    
    private func encodeVideo(withUrl videoUrl: URL) {
        self.showSpinner(withTitle: "ADD_EVENT_CONVERT_MEDIA".localized)
        
        SHOS3Utils.encodeVideo(videoUrl) { (url, error) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else if let mp4url = url {
                self.performUpload(ofVideoWithUrl: mp4url)
            }
        }
    }
    
    private func performUpload(ofVideoWithUrl url: URL) {
        self.showSpinner()

        SHOS3Utils.uploadFile(withUrl: url,
                              contentType: "video/mp4",
                              configuration: .timelineMedia(eventId: self.eventId)) { videoUrl, error in
                                
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
                
            } else if let url = videoUrl {
                let request = MediaRequestModel(type: .video, url: url)
                self.createTimelineItem(with: request)
            }
        }
    }
    
    private func createTimelineItem(with request: MediaRequestModel) {
        
        SHOAPIClient.shared.createTimelineItem(with: request,
                                               for: self.eventId) { (object, error, code) in
                                            
                                                self.dismissSpinner()
                                                self.view.endEditing(true)
                                                self.inputBar.clearText()
                                            
                                                if let error = error {
                                                    self.showErrorAlertWith(message: error.localizedDescription)
                                                } else {
                                                    self.loadData()
                                                }
        }
    }

}
