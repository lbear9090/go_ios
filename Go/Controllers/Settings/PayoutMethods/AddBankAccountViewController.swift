
//
//  AddAccountViewController.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Stripe

enum AccountSection: Int {
    case iban
    case country
    
    func placeholder() -> String {
        switch self {
        case .iban:
            return "ADD_ACCOUNT_PH_IBAN".localized
        case .country:
            return "ADD_ACCOUNT_PH_COUNTRY".localized
        }
    }
    
    public static func sectionCount() -> Int {
        return 2
    }
}

class AddBankAccountViewController: SHOTableViewController {
    
    let bankAccountParams = STPBankAccountParams()
    
    let stripeImageView = UIImageView(image: .stripeBadge)
    
    lazy var pickerView: PickerViewSheet = {
        var values = [PickerValue]()
        do {
            values = try CacheManager.getConfigurations().countries
        } catch {
            self.fetchCountries()
        }
        let picker = PickerViewSheet(with: values)
        return picker
    }()
    
    lazy var saveAccountButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "ADD_ACCOUNT_SAVE".localized
        view.config = .action
        view.delegate = self
        return view
    }()
    
    lazy var stripeManager = StripeCardManager(withController: self)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBarForUseInTabBar()
        self.title = "ADD_ACCOUNT_TITLE".localized
    }
    
    override var style: UITableViewStyle {
        return .grouped
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.tableView.backgroundView = UIView(frame: self.tableView.bounds)
        self.tableView.backgroundView?.addSubview(self.stripeImageView)
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.saveAccountButtonView)
    }
    
    override func applyConstraints() {
        
        self.tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }
        
        self.saveAccountButtonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            
            self.tableView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            self.saveAccountButtonView.snp.makeConstraints { make in
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
            
            self.saveAccountButtonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(self.tableView.snp.bottom)
            }
            
        }
    }
}

// MARK: - UITableView Methods

extension AddBankAccountViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSection.sectionCount()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sec = AccountSection(rawValue: indexPath.section) else {
            return SHOTableViewCell()
        }
        
        switch sec {
        case .iban:
            let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
            cell.topSeparatorView.isHidden = false
            cell.leftSeparatorMargin = 0
            cell.imageView?.image = UIImage.accountIcon
            cell.textField.placeholder = sec.placeholder()
            cell.textField.textColor = .text
            cell.textHandler = { [weak self, unowned cell] text in
                self?.bankAccountParams.accountNumber = text
                if let acc = self?.bankAccountParams.accountNumber, !acc.isEmpty {
                    cell.imageView?.image = UIImage.accountActiveIcon
                }
                else {
                    cell.imageView?.image = UIImage.accountIcon
                }
            }
            return cell
        case .country:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.topSeparatorView.isHidden = false
            cell.leftSeparatorMargin = 0
            cell.imageView?.image = UIImage.countryIcon
            cell.textField.textColor = .text
            cell.textField.placeholder = sec.placeholder()
            cell.textField.inputView = self.pickerView
            self.pickerView.selectionHandler = { [unowned self, cell] value in
                if let country = value as? CountryModel {
                    self.bankAccountParams.country = country.alpha2
                    self.bankAccountParams.currency = country.currency.isoCode
                }
                
                if let selection = value {
                    cell.textLabel?.text = selection.pickerValue
                    cell.textLabel?.textColor = .text
                    
                    cell.imageView?.image = UIImage.countryActiveIcon
                }
                else {
                    cell.imageView?.image = UIImage.countryIcon
                }
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == AccountSection.iban.rawValue {
            let headerView = SectionHeaderView()
            headerView.leftLabel.text = "ADD_ACCOUNT_ADD_DETAILS".localized
            headerView.leftLabel.font = Font.regular.withSize(.large)
            headerView.leftLabel.textAlignment = .center
            headerView.backgroundColor = .white
            return headerView
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = AccountSection(rawValue: section) else {
            return .leastNonzeroMagnitude
        }
        
        switch section {
        case .iban:
            return 40.0
        default:
            return 10.0
        }
    }
    
}

// MARK: - ButtonViewDelegate

extension AddBankAccountViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        if self.bankAccountParams.isValid() {
            self.fetchStripeAccountToken()
        }
        else {
            self.showErrorAlertWith(message: "PAYOUT_METHODS_ADD_ACCOUNT_MISSING_PARAMS".localized)
        }
    }
}

// MARK : - Network Calls

extension AddBankAccountViewController {
    
    func fetchStripeAccountToken() {
        self.showSpinner()
        
        let client = STPAPIClient(publishableKey: Constants.stripePublishableKey)
        client.createToken(withBankAccount: self.bankAccountParams) { (token, error) in
            
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
            }
            else if let token = token {
                self.addAccount(withToken: token.tokenId)
            }
        }
    }
    
    func addAccount(withToken accountToken: String) {
        SHOAPIClient.shared.addPayoutMethod(with: accountToken) { object, error, code in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func fetchCountries() {
        self.showSpinner()
        
        SHOAPIClient.shared.configuration { object, error, code in
            self.dismissSpinner()
            let message = "ERROR_NO_COUNTRIES".localized
            
            if let error = error {
                self.showErrorAlertWith(message: "\(message) - \(error.localizedDescription)")
                
            } else if let configuration = object as? ConfigurationsModel {
                let values = configuration.countries
                self.pickerView = PickerViewSheet(with: values)
                self.tableView.reloadData()
                
            } else {
                self.showErrorAlertWith(message:message)
            }
        }
    }
}

extension STPBankAccountParams {
    // MARK : - Verification
    func isValid() -> Bool {
        guard
            let accountNum = self.accountNumber, !accountNum.isEmpty,
            let countryName = self.country, !countryName.isEmpty
        
        else {
            return false
        }
        
        return true
        
    }
}
