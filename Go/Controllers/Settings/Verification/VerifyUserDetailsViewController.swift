//
//  VerifyUserDetailsViewController.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum UserDetailsSectionType: Int {
    case details
    case address
    case phone
    case SECTION_COUNT
    
    var title: String? {
        switch self {
        case .details:
            return "DETAILS_HEADER_GENERAL".localized
        case .address:
            return "DETAILS_HEADER_ADDRESS".localized
        case .phone:
            return "DETAILS_HEADER_CONTACT".localized
        default:
            return nil
        }
    }
}

private enum UserDetailsRow: Int {
    case dob
    case gender
    case accountType
    case country
    case ROW_COUNT
    
    var placeholder: String? {
        switch self {
        case .dob:
            return "USER_DETAILS_DOB_PH".localized
        case .gender:
            return "USER_DETAILS_GENDER_PH".localized
        case .accountType:
            return "USER_DETAILS_ACCOUNT_PH".localized
        case .country:
            return "USER_DETAILS_COUNTRY_PH".localized
        default:
            return nil
        }
    }
}

class VerifyUserDetailsViewController: SHOTableViewController {
    
    // MARK: - Properties
    
    private let user: UserModel
    
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
        datasource.address = self.user.address
        return datasource
    }()
    
    private lazy var saveButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "USER_DETAILS_SAVE".localized
        view.config = .action
        view.delegate = self
        return view
    }()
    
    // MARK: - Initializers
    
    init(user: UserModel) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "VERIFICATION_USER_DETAILS".localized
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

extension VerifyUserDetailsViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        let request = UserVerificationDetailsRequestModel(with: self.user)
        
        switch request.validate() {
        case .valid:
            self.showSpinner()
            SHOAPIClient.shared.updateMe(with: request) { (object, error, code) in
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

// MARK: - UITableView datasource

extension VerifyUserDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserDetailsSectionType.SECTION_COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = UserDetailsSectionType(rawValue: section) else {
            return 0
        }
        
        switch sectionType {
        case .details:
            return UserDetailsRow.ROW_COUNT.rawValue
        case .address:
            return self.addressSectionManager.tableView(tableView, numberOfRowsInSection: section)
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch UserDetailsSectionType(rawValue: indexPath.section) {
        case .details?:
            return self.tableView(tableView, userDetailsCellForRowAt: indexPath)
        
        case .address?:
            return self.addressSectionManager.tableView(tableView, cellForRowAt: indexPath)
        
        case .phone?:
            let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = "ADDRESS_PH_NUMBER".localized
            cell.textField.text = self.user.phoneNumber
            
            cell.textHandler = { [unowned self] text in
                self.user.phoneNumber = text
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, userDetailsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = UserDetailsRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch row {
        case .dob:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = row.placeholder
            cell.label.text = row.placeholder
            
            let datePickerView = DatePickerSheet(with: .date, responder: cell.textField)
            datePickerView.picker.maximumDate = Date()
            cell.textField.inputView = datePickerView
            
            if let dob = self.user.dateOfBirth {
                let dobDate = Date(timeIntervalSince1970: dob)
                cell.textField.text = dobDate.string(withFormat: .short)
                datePickerView.picker.setDate(dobDate, animated: false)
            }
            
            datePickerView.selectionHandler = { [unowned self, cell] date in
                if let date = date {
                    self.user.dateOfBirth = date.timeIntervalSince1970
                    cell.textField.text = date.string(withFormat: .short)
                }
            }
            return cell
            
        case .gender:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = row.placeholder
            cell.label.text = row.placeholder
            
            let values = ["VALUE_MALE".localized, "VALUE_FEMALE".localized]
            let pickerView = PickerViewSheet(with: values, responder: cell.textField)
            cell.textField.inputView = pickerView
            
            if let gender = self.user.gender {
                cell.textField.text = gender.capitalized
                pickerView.picker.setSelectedValue(gender.capitalized)
            }

            pickerView.selectionHandler = { [unowned self, cell] value in
                if let gender = value as? String {
                    self.user.gender = gender.lowercased()
                    cell.textField.text = gender
                }
            }
            
            return cell
            
        case .accountType:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = row.placeholder
            cell.label.text = row.placeholder
            
            let values = ["ACCOUNT_TYPE_INDIVIDUAL".localized, "ACCOUNT_TYPE_COMPANY".localized]
            let pickerView = PickerViewSheet(with: values, responder: cell.textField)
            cell.textField.inputView = pickerView
            
            if let accountType = self.user.accountType {
                cell.textField.text = accountType.capitalized
                //If value is set don't allow editing
                cell.isUserInteractionEnabled = false
            }
            
            pickerView.selectionHandler = { [unowned self, cell] value in
                if let accountType = value as? String {
                    self.user.accountType = accountType.lowercased()
                    cell.textField.text = accountType
                }
            }
            
            return cell
            
        case .country:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = row.placeholder
            cell.label.text = row.placeholder

            let countryPicker = PickerViewSheet(with: countries, responder: cell.textField)
            cell.textField.inputView = countryPicker
            
            if let country = self.user.countryOfResidence {
                cell.textField.text = country.name
                //If value is set don't allow editing
                cell.isUserInteractionEnabled = false
            }
            
            countryPicker.selectionHandler = { [unowned self, cell] value in
                if let country = value as? CountryModel {
                    self.user.countryOfResidence = country
                    cell.textField.text = country.name
                }
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableView delegate

extension VerifyUserDetailsViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = UserDetailsSectionType(rawValue: section) else {
            return nil
        }
        
        let headerView = SectionHeaderView()

        headerView.leftLabel.text = section.title
        headerView.leftLabel.textColor = .green
        headerView.leftLabel.font = Font.medium.withSize(.medium)
        headerView.backgroundColor = .white
        
        return headerView
    }
    
}
