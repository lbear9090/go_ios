//
//  PayoutMethodsViewController.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class PayoutMethodsViewController: SHOTableViewController {
    
    lazy var stripeImageView = UIImageView(image: .stripeBadge)
    
    lazy var addCardButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "PAYOUT_METHODS_ADD_ACCOUNT".localized
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControlDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "PAYOUT_METHODS_TITLE".localized
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

extension PayoutMethodsViewController: SHORefreshable, SHOPaginatable {
    
    func loadData() {
        SHOAPIClient.shared.payoutMethods(withOffset: self.offset, limit: self.limit) { (object, error, code) in
            self.sharedCompletionHandler(object, error)
        }
    }
    
    private func deleteAccount(with id: String) {
        self.showSpinner()
        SHOAPIClient.shared.deletePayoutMethod(with: id) { (object, error, code) in
            self.dismissSpinner()
            self.offset = 0
            self.sharedCompletionHandler(object, error)
        }
    }
    
    private func setDefaultAccount(with id: String) {
        self.showSpinner()
        SHOAPIClient.shared.defaultPayoutMethod(with: id) { (object, error, code) in
            self.dismissSpinner()
            self.offset = 0
            self.sharedCompletionHandler(object, error)
        }
    }
    
}

// MARK: - UITableView Methods

extension PayoutMethodsViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PaymentMethodTableViewCell(reuseIdentifier: PaymentMethodTableViewCell.reuseIdentifier)
        
        if let bankAccount: BankAccountModel = item(at: indexPath) {
            cell.configureFor(payoutMethod: bankAccount)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let payoutMethod: BankAccountModel = item(at: indexPath) else {
            return .none
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive,
                                                title: "TABLE_VIEW_ACTION_DELETE".localized) { [unowned self] (action, indexPath) in
                                                    self.deleteAccount(with: payoutMethod.id)
        }
        
        return [deleteAction]
    }
}

// MARK: - ButtonViewDelegate

extension PayoutMethodsViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        self.stripeManager.addAccount { (data, error) in
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            }
        }
    }
    
}
