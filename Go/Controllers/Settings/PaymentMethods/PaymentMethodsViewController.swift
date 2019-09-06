//
//  PaymentMethodsViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class PaymentMethodsViewController: SHOTableViewController {
    
    lazy var stripeImageView = UIImageView(image: .stripeBadge)
    
    lazy var addCardButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "PAYMENT_METHODS_ADD_CARD".localized
        view.config = .action
        view.delegate = self
        return view
    }()
    
    lazy var stripeManager = StripeCardManager(withController: self)
    
    override func setupTableView() {
        super.setupTableView()
        
        self.tableView.allowsSelection = false
        self.defaultBackgroundView = UIView(frame: self.tableView.bounds)
        self.defaultBackgroundView?.addSubview(self.stripeImageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "PAYMENT_METHODS_TITLE".localized
        self.refreshControlDelegate = self
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.addCardButtonView)
    }
    
    override func applyConstraints() {
        
        self.tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }
        
        self.addCardButtonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            
            self.tableView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            self.addCardButtonView.snp.makeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
            
            self.tableView.contentInset.bottom = Stylesheet.safeLayoutAreaBottomScrollInset
            
            self.stripeImageView.snp.makeConstraints { (maker) in
                maker.bottom.equalToSuperview().inset(Stylesheet.safeLayoutAreaBottomScrollInset + 20)
                maker.centerX.equalToSuperview()
            }
            
        } else {
            
            self.stripeImageView.snp.makeConstraints { (maker) in
                maker.bottom.equalToSuperview().inset(20)
                maker.centerX.equalToSuperview()
            }
            
            self.addCardButtonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(self.tableView.snp.bottom)
            }
            
        }
    }
}

//MARK: - Networking

extension PaymentMethodsViewController: SHORefreshable, SHOPaginatable {
    
    func loadData() {
        SHOAPIClient.shared.paymentMethods(withOffset: self.offset, limit: self.limit) { (object, error, code) in
            self.sharedCompletionHandler(object, error)
        }
    }
    
    private func deleteCard(with id: Int64) {
        self.showSpinner()
        SHOAPIClient.shared.deletePaymentMethod(with: id) { (object, error, code) in
            self.dismissSpinner()
            self.offset = 0
            self.sharedCompletionHandler(object, error)
        }
    }
    
    private func setDefaultCard(with id: Int64) {
        self.showSpinner()
        SHOAPIClient.shared.defaultPaymentMethod(with: id) { (object, error, code) in
            self.dismissSpinner()
            self.offset = 0
            self.sharedCompletionHandler(object, error)
        }
    }

}

// MARK: - UITableView Methods

extension PaymentMethodsViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PaymentMethodTableViewCell(reuseIdentifier: PaymentMethodTableViewCell.reuseIdentifier)
        
        if let paymentMethod: PaymentMethodModel = item(at: indexPath) {
            cell.configureFor(paymentMethod: paymentMethod)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let paymentMethod: PaymentMethodModel = item(at: indexPath) else {
            return .none
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive,
                                                title: "TABLE_VIEW_ACTION_DELETE".localized) { [unowned self] (action, indexPath) in
                                                        self.deleteCard(with: paymentMethod.id)
        }
        
        let defaultAction = UITableViewRowAction(style: .default,
                                                 title: "TABLE_VIEW_ACTION_DEFAULT".localized) { (action, indexPath) in
                                                        self.setDefaultCard(with: paymentMethod.id)
        }
        defaultAction.backgroundColor = .gray
        
        return [deleteAction, defaultAction]
    }
}

// MARK: - ButtonViewDelegate

extension PaymentMethodsViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        self.stripeManager.addCard { [unowned self] (data, error) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
                
            } else if let items = data as? [Any] {
                
                self.items = items
                self.dismiss(animated: true, completion: {
                    self.tableView.reloadData()
                })
                
            }
        }
    }
    
}
