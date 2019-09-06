//
//  EditEventViewController.swift
//  Go
//
//  Created by Lucky on 26/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class EditEventViewController: CreateEventViewController {
    
    var event: EventModel!
    
    private lazy var successAlert: UIAlertController = {
        let okAction = UIViewController.okAction { [unowned self] alert in
            self.navigationController?.dismiss(animated: true, completion: {
                if let tabBar = AppDelegate.shared?.window?.rootViewController as? UITabBarController {
                    let controller = SelectEventInviteesViewController(with: self.event.eventId)
                    let navController = UINavigationController(rootViewController: controller)
                    tabBar.present(navController, animated: true)
                }
            })
        }
        let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                               message: "UPDATE_EVENT_SUCCESS_MSG".localized,
                                               actions: [okAction])
        return alert
    }()
    
    init(withEvent event: EventModel) {
        super.init(nibName: nil, bundle: nil)
        self.event = event
        self.requestModel = AddEventRequestModel(forEvent: self.event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "EDIT_EVENT_TITLE".localized
        self.buttonView.button.setTitle("EDIT_EVENT_BUTTON".localized, for: .normal)
        
        if let mediaItem = self.event.mediaItems.first,
            let urlStr = mediaItem.images?.largeUrl,
            let url = URL(string: urlStr) {
            self.headerView.imageView.kf.setImage(with: url,
                                                  placeholder: UIImage.addEvent)
            self.headerView.videoPlayer.isHidden = (mediaItem.type != .video)
            
            if let urlStr = mediaItem.videoUrl,
                let videoURL = URL(string: urlStr), mediaItem.type == .video {
                self.headerView.videoPlayer.videoURL = videoURL
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch CreateEventSection(rawValue: section) {
        case .privateEvent?:
            return 1
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, privateEventCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Don't allow a private event to be updated to be public
        let cell = super.tableView(tableView, privateEventCellForRowAt: indexPath)
        if let cellSwitch = cell.accessoryView as? UISwitch {
            cellSwitch.isEnabled = !self.event.isPrivate
        }
        return cell
    }
    
    // MARK: - User Actions
    
    @objc override func actionButtonPressed() {
        self.view.endEditing(true)
        
        switch self.requestModel.validate() {
        case .valid:
            self.handleMediaUpload { error in
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                } else {
                    self.updateEvent()
                }
            }
            
        case .invalid(let errorString):
            self.showErrorAlertWith(message: errorString)
        }
    }
    
    // MARK: - Networking
    
    func updateEvent() {
        self.showSpinner()
        
        SHOAPIClient.shared.updateEvent(eventID: self.event.eventId, request: self.requestModel) { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.present(self.successAlert, animated: true)
            }
        }
    }

}
