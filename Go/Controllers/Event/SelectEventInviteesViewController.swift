//
//  SelectEventInviteesViewController.swift
//  Go
//
//  Created by Lucky on 08/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SelectEventInviteesViewController: SelectFriendsViewController {
    
    private let eventId: Int64
    private let handler: ((EventModel) -> Void)?
    private var event: EventModel?

    override var selectedUsers: [UserModel] {
        didSet {
            self.doneButton.isEnabled = self.validSelection
        }
    }
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(doneTapped))
        button.tintColor = .green
        button.isEnabled = false
        return button
    }()
    
    public lazy var buttonView: ButtonView = {
        let size = CGSize(width: self.view.bounds.width, height: 60)
        let frame = CGRect(origin: .zero, size: size)
        let view = ButtonView(frame: frame)
        
        view.button.setTitle("CONTINUE".localized, for: .normal)
        view.button.addTarget(self,
                              action: #selector(continueButtonTapped),
                              for: .touchUpInside)
        return view
    }()
    
    private let inviteAllLabel: UILabel = {
        let label: UILabel = UILabel.newAutoLayout()
        
        label.font = Font.regular.withSize(.large)
        label.textColor = .green
        label.text = "INVITE_ALL_FRIENDS".localized
        
        return label
    }()
    
    private let inviteAllSwitch: UISwitch = {
        let swtch = UISwitch()
        
        swtch.onTintColor = .green
        let selector = #selector(inviteAllFriends)
        swtch.addTarget(self, action: selector, for: .valueChanged)
        
        return swtch
    }()
    
    private let toolbarSeparator: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()

    private lazy var toolbarView: UIView = {
        let view: UIView = UIView.newAutoLayout()
        
        view.addSubview(self.inviteAllLabel)
        view.addSubview(self.inviteAllSwitch)
        view.addSubview(self.toolbarSeparator)
        
        return view
    }()
    
    private var validSelection: Bool {
        return selectedUsers.count > 0 || self.inviteAllSwitch.isOn
    }
    
    //MARK: - Init methods
    
    init(with eventId: Int64, eventUpdatedHandler: ((EventModel) -> Void)? = nil) {
        self.eventId = eventId
        self.handler = eventUpdatedHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = self.doneButton
        self.showSelectedView(self.selectedUsers.count > 0)
    }
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.toolbarView)
        self.view.addSubview(self.buttonView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.toolbarView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.collectionViewTopConstraint?.deactivate()
        self.selectionCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.toolbarView.snp.bottom)
        }
        
        self.inviteAllLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        self.inviteAllSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
        
        self.toolbarSeparator.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        self.tableViewBottomConstraint?.deactivate()
        
        self.buttonView.snp.makeConstraints { (make) in
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.top.equalTo(self.tableView.snp.bottom)
            make.height.equalTo(60)
        }
    }
    
    // MARK: - Network
    
    override func loadSearchResults() {
        SHOAPIClient.shared.getUninvitedFriends(for: self.eventId,
                                                withTerm: self.searchString,
                                                offset: self.offset,
                                                limit: self.limit) { object, error, code in
                                                    
                                                    if error == nil && self.searchString == nil &&
                                                        self.offset == 0 && (object as! Array<Any>).isEmpty {
                                                        
                                                        self.showAllFriendsInvitedAlert()
                                                        self.inviteAllSwitch.setOn(true, animated: true)
                                                        self.inviteAllSwitch.isUserInteractionEnabled = false
                                                    
                                                    } else {
                                                        self.sharedCompletionHandler(object, error)
                                                    }
        }
    }
    
    func updateEventWithInvitees(shouldPop: Bool) {
        self.showSpinner()
        
        let request = EventAttendeesRequestModel(attendees: self.selectedUsers,
                                                 inviteAllFriends: self.inviteAllSwitch.isOn)
        
        SHOAPIClient.shared.updateEvent(eventID: self.eventId,
                                        request: request) { object, error, code in
                                            self.dismissSpinner()
                                            
                                            if let error = error {
                                                self.showErrorAlertWith(message: error.localizedDescription)
                                            } else {
                                                if let event = object as? EventModel {
                                                    self.handler?(event)
                                                }
                                                
                                                if shouldPop {
                                                    self.navigationController?.dismissModal()
                                                }
                                                else {
                                                    self.navigateToFindFriends(object as? EventModel)
                                                }
                                            }
        }
    }
    
    //MARK: - User interaction
    
    @objc func doneTapped() {
        self.updateEventWithInvitees(shouldPop: true)
    }
    
    @objc func continueButtonTapped() {
        self.updateEventWithInvitees(shouldPop: false)
    }
    
    @objc private func inviteAllFriends(sender: UISwitch) {
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = sender.isOn ? 0 : 1
            self.selectionCollectionView.alpha = sender.isOn ? 0 : 1
        }
        let searchBar = self.searchManager.searchController.searchBar
        searchBar.isUserInteractionEnabled = !sender.isOn
        
        self.doneButton.isEnabled = self.validSelection
    }
    
    //MARK: - Helpers
    
    private func showAllFriendsInvitedAlert() {
        let dismissAction = UIViewController.dismissAction { [unowned self] action in
            self.navigationController?.popViewController(animated: true)
        }
        let alert = UIViewController.alertWith(title: "ERROR_ALERT_TITLE".localized,
                                               message: "ALL_FRIENDS_INVITED_MSG".localized,
                                               actions: [dismissAction])
        self.present(alert, animated: true)
    }
    
    func navigateToFindFriends(_ event: EventModel? = nil) {
        let controller = InviteToEventViewController(with: [InviteFBUserToEventViewController(withEventId: self.eventId),
                                                            InviteContactToEventViewController(with: self.eventId)])
        controller.addNavBarLogo = false
        controller.title = "SETTINGS_FIND_FRIENDS".localized
        controller.event = event
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - SearchControllerManagerDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.inviteAllSwitch.isUserInteractionEnabled = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.inviteAllSwitch.isUserInteractionEnabled = true
    }
}
