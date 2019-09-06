//
//  NameGroupViewController.swift
//  Go
//
//  Created by Lee Whelan on 24/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class NameGroupViewController: SHOTableViewController {

    var selectedUsers: [UserModel]?
    
    var groupName: String?

    var groupImage: UIImage? {
        didSet {
            self.headerView.groupImageView.image = self.groupImage
        }
    }
    
    lazy var headerView: NameGroupDetailView = {
        var view: NameGroupDetailView = NameGroupDetailView.newAutoLayout()
        view.delegate = self
        return view
    }()
    
    lazy var buttonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "CHAT_NEW_GROUP_NEXT".localized.uppercased()
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "CHAT_NEW_GROUP_TITLE".localized
    }
    
    //MARK: Setup
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.buttonView)
    }
    
    override func applyConstraints() {

        self.headerView.snp.makeConstraints { make in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.right.left.equalToSuperview()
        }
        
        self.buttonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            
            self.tableView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            self.buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
            
            self.tableView.contentInset.bottom = Stylesheet.safeLayoutAreaBottomScrollInset
            
        } else {
            
            self.buttonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(self.tableView.snp.bottom)
            }
            
        }

    }
    
    //MARK: TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedUsers?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserTableViewCell = UserTableViewCell.reusableCell(from: tableView)
        cell.accessoryType = .checkmark
        cell.selectionStyle = .none
        cell.tintColor = .green
                
        if let user = self.selectedUsers?[indexPath.row] {
            cell.populate(with: user)
        
            cell.attendingIconTappedHandler = { [unowned self] in
                let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
                controller.initialEventsType = .attending
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        return cell
    }

}

//MARK: - NameGroupViewDelegate -

extension NameGroupViewController: NameGroupDetailViewDelegate {
    
    func nameGroupDetailView(_ view: NameGroupDetailView, didSelectImageView imageView: UIImageView) {
        let imagePicker = SHOImagePickerUtils(with: self)
        imagePicker.openImageActionSheet(withSelectionHandler: { [unowned self] (images) in
            self.groupImage = images.first
        })
    }
    
    func nameGroupDetailView(_ view: NameGroupDetailView, textDidChange text: String?) {
        self.groupName = text
    }
    
}

// MARK: - ButtonViewDelegate -

extension NameGroupViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        guard let name = self.groupName else {
            self.showErrorAlertWith(message: "GROUP_NAME_MISSING_ERROR".localized)
            return
        }
        
        guard let participants = self.selectedUsers, participants.count > 0 else {
            self.showErrorAlertWith(message: "GROUP_PARTICIPANTS_MISSING_ERROR".localized)
            return
        }
        
        let request = ConversationRequest(name: name, participants: participants)
        
        if let image = self.groupImage {
            self.upload(image, completion: { [weak self] (imageURL) in
                if let url = imageURL {
                    request.imageURL = url
                    self?.create(request)
                }
            })
        }
        else {
            self.create(request)
        }
    }
    
}

// MARK: - Networking Methods

extension NameGroupViewController {
    
    func upload(_ image: UIImage, completion: ((String?) -> Void)?) {
        self.showSpinner()
        
        SHOS3Utils.upload(image, configuration: .chatAttachment(userID: nil)) { (url, error) in
            self.dismissModal()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            
            completion?(url)
        }
    }
    
    func create(_ requestModel: ConversationRequest) {
        self.showSpinner()
        
        SHOAPIClient.shared.create(requestModel) { (data, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else {
                if let conversation = data as? Conversation {
                    self.navigationController?.pushViewController(ConversationThreadViewController(conversation: conversation), animated: true)
                    
                    if let viewControllers = self.navigationController?.viewControllers,
                        let firstVC = viewControllers.first,
                        let lastVC = viewControllers.last {
                        
                        self.navigationController?.viewControllers = [firstVC, lastVC]
                    }
                    
                    
                }
                else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
