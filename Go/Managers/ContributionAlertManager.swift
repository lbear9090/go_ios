//
//  ContributionAlertManager.swift
//  Go
//
//  Created by Killian-Kenny on 02/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class ContributionAlertManager {
    
    typealias AmountSelectedHandler = ((Int) -> Void)?
    public var amountSelectedHandler: AmountSelectedHandler
    
    private weak var controller: SHOViewController?
    private var contribution: EventContributionModel!
    private var contributionAmount: Int!
    
    init(for controller: SHOViewController) {
        self.controller = controller
    }
    
    func showAlert(for event: EventModel, with handler: AmountSelectedHandler) {
        guard let contribution = event.contribution else {
            return
        }
        self.amountSelectedHandler = handler
        self.contribution = contribution
        self.contributionAmount = contribution.amount.cents
        
        let okAction = SHOViewController.okAction { [weak self] action in
            if let sSelf = self {
                sSelf.amountSelectedHandler?(sSelf.contributionAmount)
            }
        }
        
        let noAction = UIAlertAction(title: "ALERT_ACTION_NO_THANKS".localized,
                                     style: .cancel)
        
        let changeAmountAction = UIAlertAction(title: "EVENT_CONTRIBUTION_CHANGE_AMOUNT".localized,
                                               style: .default) { [weak self] action in
                                                self?.showChangeAmountAlert(for: event)
        }
        
        var actions = [okAction, noAction]
        if contribution.optional {
            actions.append(changeAmountAction)
        }
        
        actions.forEach { $0.setValue(UIColor.text, forKey: "titleTextColor") }
        
        let alert = SHOViewController.alertWith(title: contribution.type.alertTitle,
                                                message: contribution.type.alertMsg,
                                                actions: actions)
        
        if let controller = self.controller {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showChangeAmountAlert(for event: EventModel) {
        guard let contribution = event.contribution else {
            return
        }
        
        let okAction = UIViewController.okAction { [weak self] action in
            if let sSelf = self {
                sSelf.showTotalContributionAlert(for: sSelf.contributionAmount, on: event)
            }
        }
        
        let noAction = UIAlertAction(title: "ALERT_ACTION_NO_THANKS".localized,
                                     style: .cancel)
        
        let actions = [okAction, noAction]
        actions.forEach { $0.setValue(UIColor.text, forKey: "titleTextColor") }
        
        let alert = SHOViewController.alertWith(title: contribution.type.changeAmountTitle,
                                                message: contribution.type.changeAmountMsg,
                                                actions: actions)
        
        alert.addTextField { textField in
            let amountString = "\(contribution.amount.currency.symbol)\(contribution.amount.cents/100)"
            textField.placeholder = amountString
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        if let controller = self.controller {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showTotalContributionAlert(for selectedAmount: Int, on event: EventModel) {
        
        guard let attendeeId = event.userAttendance?.id else {
            self.controller?.showSpinner()
            SHOAPIClient.shared.setAtttendanceStatus(.pending, forEventId: event.eventId) { object, error, code in
                if let error = error {
                    self.controller?.showErrorAlertWith(message: error.localizedDescription)
                } else if let attendance = object as? AttendeeModel {
                    event.userAttendance = attendance
                    self.showTotalContributionAlert(for: selectedAmount, on: event)
                } else {
                    self.controller?.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
                }
            }
            return
        }
        
        self.controller?.showSpinner()
        SHOAPIClient.shared.getTotalContribution(for: selectedAmount,
                                                 on: event.eventId,
                                                 from: attendeeId) { object, error, code in
                                                    self.controller?.dismissSpinner()
                                                    
                                                    if let totalQuote = object as? AttendeeContributionQuoteModel {
                                                        
                                                        let okAction = UIViewController.okAction { [weak self] action in
                                                            if let sSelf = self {
                                                                sSelf.amountSelectedHandler?(selectedAmount)
                                                            }
                                                        }
                                                        let cancelAction = UIViewController.cancelAction()
                                                        
                                                        let actions = [okAction, cancelAction]
                                                        actions.forEach { $0.setValue(UIColor.text, forKey: "titleTextColor") }
                                                        
                                                        let alert = UIViewController.alertWith(title: nil,
                                                                                               message: totalQuote.message,
                                                                                               actions: actions)
                                                        self.controller?.present(alert, animated: true, completion: nil)
                                                        
                                                    } else {
                                                        self.controller?.showErrorAlertWith(message: error?.localizedDescription)
                                                    }
        }
    }
    
    @objc private func textChanged(_ sender: UITextField) {
        
        if var string = sender.text {
            if let first = string.first,
                String(first) == self.contribution.amount.currency.symbol {
                string.removeFirst()
            }
            
            if let amountInput = Int(string) {
                self.contributionAmount = amountInput * 100
            } else {
                self.contributionAmount = self.contribution.amount.cents
            }
            
            if string.count > 0 {
                sender.text = "\(self.contribution.amount.currency.symbol)\(string)"
            } else {
                sender.text = nil
            }
        }
    }
    
}
