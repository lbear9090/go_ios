//
//  CommentsViewController.swift
//  Go
//
//  Created by Lucky on 07/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit
import MessageKit

class CommentsViewController: SHOTableViewController {
    
    let eventId: Int64
    let timelineId: Int64
    var currentUser: UserModel?
    var bottomConstraint: Constraint?

    lazy var inputBar: GoMessageInputBar = {
        let bar: GoMessageInputBar = GoMessageInputBar.newAutoLayout()
        
        bar.customDelegate = self
        
        // text view
        bar.inputTextView.placeholder = ""
        bar.inputTextView.layer.cornerRadius = 15
        bar.inputTextView.layer.borderWidth = 0.5
        bar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        
        // right stack view
        bar.setRightStackViewWidthConstant(to: 30, animated: true)
        bar.setStackViewItems([bar.sendInputBarButtonItem], forStack: .right, animated: true)
        
        return bar
    }()
    
    //MARK: - Init
    
    init(eventId: Int64, timelineId: Int64) {
        self.eventId = eventId
        self.timelineId = timelineId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControlDelegate = self
        self.fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "COMMENTS_TITLE".localized
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.inputBar)
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.keyboardDismissMode = .interactive
    }
    
    private func fetchUser() {
        CacheManager.getCurrentUser { (user, error) in
            self.currentUser = user
        }
    }
    
    //MARK: - Constraints
    
    override func applyConstraints() {
        self.tableView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }

        self.inputBar.snp.makeConstraints { make in
            bottomConstraint = make.bottom.equalToSuperview().constraint
            make.left.right.equalToSuperview()
            make.top.equalTo(self.tableView.snp.bottom)
        }
    }
    
    //MARK: - Keyboard notifications
    
    override func animateLayoutForKeyboard(frame: CGRect) {
        var height = frame.size.height
        
        if let tabController = self.tabBarController, height > 0 {
            height -= tabController.tabBar.bounds.height
        }
        
        self.bottomConstraint?.update(inset: height)
    }

}

//MARK: - Networking

extension CommentsViewController: SHORefreshable, SHOPaginatable {
    
    func loadData() {
        SHOAPIClient.shared.getComments(eventId: self.eventId,
                                        timelineId: self.timelineId,
                                        offset: self.offset,
                                        limit: self.limit) { (object, error, code) in
                                            self.sharedCompletionHandler(object, error)
        }
    }
    
    func createComment(withText text: String) {
        if text.isEmpty {
            return
        }
        self.showSpinner()
        SHOAPIClient.shared.createComment(withText: text,
                                          eventId: self.eventId,
                                          timelineId: self.timelineId) { (object, error, code) in
                                            self.dismissSpinner()
                                            
                                            if let error = error {
                                                self.showErrorAlertWith(message: error.localizedDescription)
                                            } else if let comment = object as? CommentModel {
                                                self.inputBar.clearText()
                                                self.items?.insert(comment, at: 0)
                                                self.tableView.reloadData()
                                                self.tableView.backgroundView = self.isEmpty ? self.emptyStateView : self.defaultBackgroundView
                                            }
        }
                                          
    }
    
    func reportComment(withId commentId: Int64, forReason reason: ReportReason) {
        self.showSpinner()
        SHOAPIClient.shared.reportComment(withId: commentId,
                                          eventId: self.eventId,
                                          timelineId: self.timelineId,
                                          reason: reason) { (object, error, code) in
                                            self.dismissSpinner()

                                            if let error = error {
                                                self.showErrorAlertWith(message: error.localizedDescription)
                                            } else {
                                                let alert = UIViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                                                       message: "COMMENTS_REPORTED_MSG".localized,
                                                                                       actions: [UIViewController.okAction()])
                                                self.present(alert, animated: true)
                                            }
        }
    }
    
    func deleteComment(withId commentId: Int64) {
        self.showSpinner()
        SHOAPIClient.shared.deleteComment(withId: commentId,
                                          eventId: self.eventId,
                                          timelineId: self.timelineId) { (object, error, code) in
                                            self.dismissSpinner()
                                            
                                            if let error = error {
                                                self.showErrorAlertWith(message: error.localizedDescription)
                                            } else {
                                                self.refreshData()
                                            }
        }
    }
    
}

extension CommentsViewController: GoMessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: GoMessageInputBar, didPressSendButton button: InputBarButtonItem, with text: String) {
        self.createComment(withText: text)
    }

}

//MARK: - Tableview datasource & delegate

extension CommentsViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell = CommentTableViewCell.reusableCell(from: tableView)
        
        if let comment: CommentModel = item(at: indexPath) {
            cell.populate(with: comment)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let comment: CommentModel = self.item(at: indexPath) else {
            return nil
        }
        
        let reportAction = UITableViewRowAction(style: .normal, title: "COMMENTS_REPORT_ACTION".localized) { [unowned self] (action, indexPath) in
            OptionsAlertManager(for: self).presentReportReasonsSheet { reason in
                self.reportComment(withId: comment.id, forReason: reason)
            }
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "COMMENTS_DELETE_ACTION".localized) { [unowned self] (action, indexPath) in
            self.deleteComment(withId: comment.id)
        }
        
        if let user = self.currentUser, user.userId == comment.user.userId {
            return [deleteAction, reportAction]
        } else {
            return [reportAction]
        }
    }
    
}
