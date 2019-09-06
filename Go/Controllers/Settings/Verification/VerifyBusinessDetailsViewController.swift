//
//  VerifyBusinessDetailsViewController.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum Section: Int {
    case details
    case address
    case SECTION_COUNT
}

private enum DetailsRow: Int {
    case name
    case taxId
    case ROW_COUNT
    
    var placeholder: String? {
        switch self {
        case .name:
            return "BUSINESS_NAME".localized
        case .taxId:
            return "BUSINESS_TAX_ID".localized
        default:
            return nil
        }
    }
    
    func text(from business: BusinessDetailsModel) -> String? {
        switch self {
        case .name:
            return business.name
        case .taxId:
            return business.taxId
        default:
            return nil
        }
    }
    
    func setValue(_ value :String, on business: BusinessDetailsModel) {
        switch self {
        case .name:
            business.name = value
        case .taxId:
            business.taxId = value
        default:
            break
        }
    }
    
}

class VerifyBusinessDetailsViewController: SHOTableViewController {
    
    private let businessDetails: BusinessDetailsModel
    
    private lazy var countries: [CountryModel] = {
        var countries = [CountryModel]()
        do {
            countries = try CacheManager.getConfigurations().countries
        } catch {
            self.showErrorAlertWith(message: "ERROR_NO_COUNTRIES".localized)
        }
        return countries
    }()
    
    private lazy var addressSectionManager: AddressSectionDatasource = {
        let datasource = AddressSectionDatasource()
        datasource.countries = self.countries
        datasource.address = self.businessDetails.address
        return datasource
    }()
    
    private lazy var saveButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "BUSINESS_DETAILS_SAVE".localized
        view.config = .action
        view.delegate = self
        return view
    }()
    
    // MARK: - Initializers
    
    init(businessDetails: BusinessDetailsModel) {
        self.businessDetails = businessDetails
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "VERIFICATION_BUSINESS".localized
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.saveButtonView)
    }
    
    override func applyConstraints() {
        
        self.tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }
        
        self.saveButtonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            
            self.tableView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            self.saveButtonView.snp.makeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
            
            self.tableView.contentInset.bottom = Stylesheet.safeLayoutAreaBottomScrollInset
            
        } else {
            
            self.saveButtonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(self.tableView.snp.bottom)
            }
            
        }
    }
    
    //Overriden to set correct content inset when keyboard is hidden
    override func animateLayoutForKeyboard(frame: CGRect) {
        var bottomInset = frame.height
        if #available(iOS 11.0, *), bottomInset == 0 {
            bottomInset = Stylesheet.safeLayoutAreaBottomScrollInset
        }
        self.tableView.contentInset.bottom = bottomInset
        self.tableView.layoutIfNeeded()
    }
    
}

// MARK: - ButtonViewDelegate

extension VerifyBusinessDetailsViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        let requestModel = UserBusinessDetailsRequestModel(with: self.businessDetails)
        
        switch requestModel.validate() {
        case .valid:
            self.showSpinner()
            SHOAPIClient.shared.updateMe(with: requestModel) { (object, error, code) in
                self.dismissSpinner()
                
                if let error = error {
                    self.showErrorAlertWith(message: error.localizedDescription)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        case .invalid(let errorString):
            self.showErrorAlertWith(message: errorString)
        }
    }
    
}

//MARK: - Tableview datasource

extension VerifyBusinessDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.SECTION_COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionType = Section(rawValue: section),
            sectionType == .address {
            return self.addressSectionManager.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return DetailsRow.ROW_COUNT.rawValue
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let sectionType = Section(rawValue: indexPath.section),
            sectionType == .address {
            return self.addressSectionManager.tableView(tableView, cellForRowAt: indexPath)
        } else {
            return self.tableView(tableView, detailsCellForRowAt:indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, detailsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = DetailsRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
        cell.separatorView.isHidden = true
        cell.textField.placeholder = rowType.placeholder
        cell.textField.text = rowType.text(from: self.businessDetails)
        
        cell.textHandler = { [unowned self] text in
            rowType.setValue(text, on: self.businessDetails)
        }
        
        return cell
    }
    
}

//MARK: - Tableview delegate

extension VerifyBusinessDetailsViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section(rawValue: section) == .address ? 30.0 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionType = Section(rawValue: section),
            sectionType == .address {
            
            let headerView = SectionHeaderView()
            
            headerView.leftLabel.text = "BUSINESS_ADDRESS".localized
            headerView.leftLabel.textColor = .green
            headerView.leftLabel.font = Font.medium.withSize(.medium)
            headerView.backgroundColor = .white
            
            return headerView
            
        } else {
            return nil
        }
    }
    
}
