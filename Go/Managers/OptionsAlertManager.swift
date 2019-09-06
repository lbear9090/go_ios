//
//  OptionsAlertManager.swift
//  Go
//
//  Created by Lucky on 21/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Branch

class OptionsAlertManager {
    
    private weak var controller: SHOViewController?
    
    var branchUniversalObject: BranchUniversalObject?
    
    //MARK: - Init
    
    init(for controller: SHOViewController) {
        self.controller = controller
    }
    
    //MARK: - Public functions
    
    func showOptions(forUserId userId: Int64) {
        let reportAction = UIAlertAction(title: "REPORT".localized, style: .destructive) { [unowned self] action in
            self.presentReportReasonsSheet(selectedCompletion: { reason in
                self.controller?.showSpinner()
                SHOAPIClient.shared.reportUser(withId: userId,
                                               reason: reason,
                                               completionHandler: self.reportedCompletionHandler)
            })
        }
        
        let actions = [reportAction, SHOViewController.cancelAction()]
        let actionSheet = SHOViewController.actionSheetWith(title: nil,
                                                            message: "ALERT_TITLE_OPTIONS".localized,
                                                            actions: actions)
        if let actionSheet = actionSheet {
            self.controller?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func showOptions(forEvent event: EventModel, eventCancelledHandler handler: (()->Void)? = nil) {
        self.configureBranchObjectForSharing(event)
        
        CacheManager.getCurrentUser { (user, error) in
            
            let reportAction = UIAlertAction(title: "REPORT".localized, style: .destructive) { [unowned self] action in
                self.presentReportReasonsSheet(selectedCompletion: { reason in
                    self.controller?.showSpinner()
                    SHOAPIClient.shared.reportEvent(withId: event.eventId,
                                                    reason: reason,
                                                    completionHandler: self.reportedCompletionHandler)
                })
            }
            
            let deleteAction = UIAlertAction(title: "DELETE_EVENT".localized, style: .destructive) { [unowned self] action in
                let yesAction = UIViewController.yesAction { action in
                    self.deleteEvent(event, completion: handler)
                }
                let confirmationAlert = UIViewController.alertWith(title: "DELETE_EVENT".localized,
                                                                   message: "DELETE_EVENT_CONFIRM_MSG".localized,
                                                                   actions: [yesAction, UIViewController.noAction()])
                self.controller?.present(confirmationAlert, animated: true)
            }
            
            let editAction = UIAlertAction(title: "EDIT_EVENT".localized, style: .default) { [unowned self] action in
                let editVC = EditEventViewController(withEvent: event)
                let navController = UINavigationController(rootViewController: editVC)
                self.controller?.present(navController, animated: true, completion: nil)
            }
            
            var actions: [UIAlertAction] = []
            
            if let user = user, user == event.host {
                actions.append(editAction)
                actions.append(reportAction)
                actions.append(deleteAction)
            }
            else {
                actions.append(reportAction)
            }
            
            actions.append(UIViewController.cancelAction())
            
            self.showOptionsSheet(withTitle: nil, actions: actions)
        }
    }
    
    func showOptions(forTimeline timelineItem: TimelineModel, deletionHandler: @escaping (()->Void)) {
        CacheManager.getCurrentUser { (user, error) in
            
            let reportAction = UIAlertAction(title: "REPORT".localized, style: .destructive) { [unowned self] action in
                self.presentReportReasonsSheet(selectedCompletion: { reason in
                    self.controller?.showSpinner()
                    SHOAPIClient.shared.reportTimelineItem(with: timelineItem.id,
                                                           from: timelineItem.associatedEventId,
                                                           reason: reason,
                                                           completionHandler: self.reportedCompletionHandler)
                })
            }
            
            let deleteAction = UIAlertAction(title: "DELETE_TIMELINE_ITEM".localized, style: .destructive) { [unowned self] action in
                let yesAction = UIViewController.yesAction { action in
                    self.controller?.showSpinner()
                    SHOAPIClient.shared.deleteTimelineItem(with: timelineItem.id,
                                                           from: timelineItem.associatedEventId,
                                                           completionHandler: { (object, error, code) in
                                                            self.controller?.dismissSpinner()

                                                            if let error = error {
                                                                self.controller?.showErrorAlertWith(message: error.localizedDescription)
                                                            } else {
                                                                deletionHandler()
                                                            }
                    })
                }
                
                let confirmationAlert = UIViewController.alertWith(title: "DELETE_TIMELINE_ITEM".localized,
                                                                   message: "DELETE_TIMELINE_ITEM_CONFIRM_MSG".localized,
                                                                   actions: [yesAction, UIViewController.noAction()])
                self.controller?.present(confirmationAlert, animated: true)
            }
            
            var actions = [UIAlertAction]()
            
            if user == timelineItem.user {
                actions.append(deleteAction)
            } else {
                actions.append(reportAction)
            }
            
            actions.append(UIViewController.cancelAction())
            
            self.showOptionsSheet(withTitle: nil, actions: actions)
        }
    }
    
    func presentReportReasonsSheet(selectedCompletion: @escaping (ReportReason) -> Void) {
        let spamAction = UIAlertAction(title: "REASON_SPAM".localized, style: .destructive) { action in
            selectedCompletion(.spam)
        }
        
        let inappropriateAction = UIAlertAction(title: "REASON_INAPPROPRIATE".localized, style: .destructive) { action in
            selectedCompletion(.inappropriate)
        }
        
        let actions = [spamAction, inappropriateAction, UIViewController.cancelAction()]
        showOptionsSheet(withTitle: "REPORT_REASON".localized, actions: actions)
    }
    
    //MARK: - Private functions
    
    private func showOptionsSheet(withTitle: String?, actions: [UIAlertAction]) {
        let actionSheet = SHOViewController.actionSheetWith(title: withTitle,
                                                            message: nil,
                                                            actions: actions)
        if let actionSheet = actionSheet {
            self.controller?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func deleteEvent(_ event: EventModel, completion deletedHandler: (()->Void)?) {
        self.controller?.showSpinner()
        
        SHOAPIClient.shared.deleteEvent(withId: event.eventId) { (object, error, code) in
            self.controller?.dismissSpinner()

            if let error = error {
                self.controller?.showErrorAlertWith(message: error.localizedDescription)
            } else {
                deletedHandler?()
            }
        }
    }
    
    private func reportedCompletionHandler(_ data: Any?, _ error: Error?, _ statusCode: Int) {
        self.controller?.dismissSpinner()
        
        if let error = error {
            self.controller?.showErrorAlertWith(message: error.localizedDescription)
        } else {
            let successAlert = SHOViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                           message: "REPORTED_SUCCESS_MSG".localized,
                                                           actions: [SHOViewController.dismissAction()])
            self.controller?.present(successAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Share Methods
    
    public func configureBranchObjectForSharing(_ event: EventModel) {
        let canonicalID = "\(Date().timeIntervalSince1970)"
        
        self.branchUniversalObject = BranchUniversalObject(canonicalIdentifier: canonicalID)
        self.branchUniversalObject?.title = event.title
        self.branchUniversalObject?.contentDescription = event.description
        self.branchUniversalObject?.publiclyIndex = true
        self.branchUniversalObject?.imageUrl = event.mediaItems.first?.images?.sharingUrl
        
    }
    
    public func showSharingOptions(event: EventModel) {
        guard let branchObject = self.branchUniversalObject else {
            return
        }
        
        let linkProperties = BranchLinkProperties()
        linkProperties.addControlParam(Constants.branchEventIDKey, withValue: "\(event.eventId)")
        linkProperties.feature = "Sharing"
        
        let shareText = "\("EVENT_BRANCH_SHARE_TEXT".localized) \(event.title)"
        branchObject.showShareSheet(with: linkProperties,
                                    andShareText: shareText,
                                    from: self.controller,
                                    completion: nil)
    }
    
}
