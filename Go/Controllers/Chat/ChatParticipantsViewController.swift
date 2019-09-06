//
//  ChatParticipantsViewController.swift
//  Go
//
//  Created by Lucky on 19/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class ChatParticipantsViewController: SHOTableViewController {
    
    private var conversation: Conversation
    
    private lazy var friendManager = FriendshipManager(with: self)

    init(conversation: Conversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CONVERSATION_PARTICIPANTS_TITLE".localized
        self.loadParticipants()
    }
    
    //MARK: - Networking
    
    func loadParticipants() {
        self.showSpinner()
        SHOAPIClient.shared.loadParticipants(withId: self.conversation.id) { (object, error, code) in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let participant = object as? [Participant] {
                self.conversation.participants = participant
                self.tableView.reloadData()
            }
        }
    }
    
    func removeParticipant(_ participant: Participant) {
        self.showSpinner()
        SHOAPIClient.shared.removeParticipant(withId: participant.id, from: self.conversation.id) { (object, error, code) in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.loadParticipants()
            }
        }
    }
    
    //MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversation.participants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participant = self.conversation.participants[indexPath.row]
        
        let cell: FriendableUserTableViewCell = FriendableUserTableViewCell.reusableCell(from: tableView)
        cell.populate(with: participant.instance)
        cell.friendButton.setManager(self.friendManager)
        return cell
    }
    
    //MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.conversation.participants[indexPath.row].instance
        let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.conversation.owner
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard self.conversation.owner else {
            return nil
        }
        
        let removeAction = UITableViewRowAction(style: .destructive,
                                                title: "CONVERSATION_PARTICIPANTS_REMOVE".localized) { [unowned self] (action, indexPath) in
                                                    let participant = self.conversation.participants[indexPath.row]
                                                    self.removeParticipant(participant)
        }

        return [removeAction]
    }

}
