//
//  EditProfileViewController.swift
//  Go
//
//  Created by Lucky on 12/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum SectionType: Int {
    case section1
    case section2
    case section3
    case section4
}

private enum EditProfileRow: Int {
    case companyName
    case firstName
    case lastName
    case description
    case dob
    case gender
    case phone
    case email
    case over18
    case calendar
    case interests
    
    func title(for userType: UserType = .personal) -> String? {
        switch self {
        case .companyName:
            return "EDIT_PROFILE_COMPANY_NAME".localized
        case .firstName:
            if userType == .business {
                return "EDIT_PROFILE_CONTACT_FIRST_NAME".localized
            }
            return "EDIT_PROFILE_FIRST_NAME".localized
        case .lastName:
            if userType == .business {
                return "EDIT_PROFILE_CONTACT_LAST_NAME".localized
            }
            return "EDIT_PROFILE_LAST_NAME".localized
        case .dob:
            return "EDIT_PROFILE_DOB".localized
        case .gender:
            return "EDIT_PROFILE_GENDER".localized
        case .phone:
            return "EDIT_PROFILE_PHONE".localized
        case .email:
            return "EDIT_PROFILE_EMAIL".localized
        case .over18:
            return "EDIT_PROFILE_OVER_18".localized
        case .calendar:
            return "EDIT_PROFILE_ADD_TO_CALENDAR".localized
        case .interests:
            return "EDIT_PROFILE_INTERESTS".localized
        default:
            return nil
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .companyName:
            return .companyNameIcon
        case .firstName, .lastName:
            return .profileNameIcon
        case .dob:
            return .profileDOBIcon
        case .gender:
            return .profileGenderIcon
        case .phone:
            return .profilePhoneIcon
        case .email:
            return .profileEmailIcon
        case .over18:
            return .adultOnly
        case .calendar:
            return .profileSyncIcon
        case .interests:
            return .hashTag
        default:
            return nil
        }
    }
    
    func text(from user: UserModel?) -> String? {
        switch self {
        case .companyName:
            return user?.businessName
        case .firstName:
            return user?.firstName
        case .lastName:
            return user?.lastName
        case .gender:
            return user?.gender?.capitalized
        case .phone:
            return user?.phoneNumber
        case .email:
            return user?.email
        default:
            return nil
        }
    }
    
    func setText(_ text: String, on user: UserModel?) {
        switch self {
        case .companyName:
            user?.businessName = text
        case .firstName:
            user?.firstName = text
        case .lastName:
            user?.lastName = text
        case .email:
            user?.email = text
        case .phone:
            user?.phoneNumber = text
        default:
            break
        }
    }
}

private struct Section {
    var type: SectionType
    var items: [EditProfileRow]
}

class EditProfileViewController: SHOTableViewController {
    
    private let sections: [Section] = [
        Section(type: .section1, items: [.companyName]),
        Section(type: .section2, items: [.firstName, .lastName, .description]),
        Section(type: .section3, items: [.dob, .gender]),
        Section(type: .section4, items: [.phone, .email, .over18, .calendar, .interests])
    ]
    
    private var user: UserModel? {
        didSet {
            self.tableView.reloadData()
            if let avatarUrl = self.user?.avatarImage?.mediumUrl {
                self.headerView.avatarImageView.kf.setImage(with: URL(string: avatarUrl),
                                                            placeholder: UIImage.avatarPlaceholder)
            }
            if let coverUrl = self.user?.coverImage?.largeUrl {
                self.headerView.headerImageView.kf.setImage(with: URL(string: coverUrl),
                                                            placeholder: UIImage.headerPlaceholder)
            }
        }
    }
    
    private var avatarImage: UIImage?
    private var coverImage: UIImage?
    
    private lazy var imagePicker = SHOImagePickerUtils(with: self)
    
    private lazy var headerView: EditProfileHeaderView = {
        let header = EditProfileHeaderView(frame: .zero)
        header.autoresize(for: self.view.bounds.size)
        
        header.avatarTapHandler = { [unowned self] imageView in
            self.imagePicker.openImageActionSheet(withSelectionHandler: { (images) in
                imageView.image = images.first
                self.avatarImage = images.first
            })
        }
        
        header.coverTapHandler = { [unowned self] imageView in
            self.imagePicker.openImageActionSheet(withSelectionHandler: { (images) in
                imageView.image = images.first
                self.coverImage = images.first
            })
        }
        return header
    }()
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(image: UIImage.saveIcon,
                                     style: .plain,
                                     target: self,
                                     action: #selector(saveButtonPressed))
        self.navigationItem.rightBarButtonItem = button
        
        self.fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "EDIT_PROFILE_TITLE".localized
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.tableHeaderView = self.headerView
    }
    
    // MARK: - User Action
    
    @objc func saveButtonPressed() {
        guard let user = self.user else {
            return
        }
        self.view.endEditing(false)
        
        let request = UserProfileRequestModel(with: user)
        switch request.validate() {
        case .valid:
            self.handleAvatarUpload(with: request)
        case .invalid(let errorString):
            self.showErrorAlertWith(message: errorString)
        }
    }
    
    private func showSuccessAlert() {
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: { [unowned self] action in
            self.navigationController?.popViewController(animated: true)
        })
        
        let successAlert = SHOViewController.alertWith(title: "ALERT_SUCCESS".localized,
                                                       message: "EDIT_PROFILE_SUCCESS_MSG".localized,
                                                       actions: [okAction])
        
        self.present(successAlert, animated: true, completion: nil)
    }
    
    // MARK: - Networking
    
    private func fetchUser() {
        self.showSpinner()
        SHOAPIClient.shared.getMe { object, error, code in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription,
                                        completion: {
                                            self.navigationController?.popViewController(animated: true)
                })
            } else if let user = object as? UserModel {
                self.user = user
            }
        }
    }
    
    private func handleAvatarUpload(with request: UserProfileRequestModel) {
        guard let user = self.user else {
            return
        }
        self.showSpinner()
        var request = request

        if let avatar = self.avatarImage,
            let email = user.email {
            
            SHOS3Utils.upload(avatar, configuration: .avatar(email: email),
                              completionHandler: { imageUrl, error in
                                if let error = error {
                                    self.dismissSpinner()
                                    self.showErrorAlertWith(message: error.localizedDescription)
                                } else {
                                    request.avatarImageUrl = imageUrl
                                    self.handleCoverImageUpload(with: request)
                                }
            })
        } else {
            self.handleCoverImageUpload(with: request)
        }
    }
    
    private func handleCoverImageUpload(with request: UserProfileRequestModel) {
        guard let user = self.user else {
            return
        }
        var request = request
        
        if let coverImage = self.coverImage,
            let email = user.email {
            
            SHOS3Utils.upload(coverImage, configuration: .coverImage(email: email),
                              completionHandler: { imageUrl, error in
                                if let error = error {
                                    self.dismissSpinner()
                                    self.showErrorAlertWith(message: error.localizedDescription)
                                } else {
                                    request.coverImageUrl = imageUrl
                                    self.updateUser(with: request)
                                }
            })
        } else {
            self.updateUser(with: request)
        }
    }
    
    private func updateUser(with request: UserProfileRequestModel) {
        SHOAPIClient.shared.updateMe(with: request, completion: { object, error, code in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.showSuccessAlert()
            }
        })
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = sections[indexPath.section].items[indexPath.row]

        if row == .email, let email = user?.email {
            
            let controller = VerifyEmailViewController(email: email, mailSentCompletion: { [unowned self] in
                self.fetchUser()
            })
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
        if row == .interests {
            if let tags = self.user?.tags {
                let controller = UpdateInterestsViewController(selectedTags: tags) { [unowned self] in
                    self.fetchUser()
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    // MARK: - UITableView Datasource
    
    override func numberOfSections(in tableview: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        
        switch section.type {
        case .section1:
            return self.user?.userType == .business ? section.items.count : 0
        case .section3:
            return self.user?.userType == .business ? 0 : section.items.count
        default:
            return section.items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
            
        case .companyName, .firstName, .lastName, .phone:
            let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
                cell.textField.autocorrectionType = .no
            }
            cell.imageView?.image = row.icon
            cell.label.text = row.title(for: self.user?.userType ?? .personal)
            cell.textField.placeholder = row.title()
            cell.textField.text = row.text(from: self.user)
            
            cell.textHandler = { [unowned self] text in
                row.setText(text, on: self.user)
            }
            
            return cell
            
        case .email:
            let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView, withStyle: .value1) { cell in
                cell.separatorView.isHidden = true
                cell.textLabel?.font = Font.regular.withSize(.large)
                cell.detailTextLabel?.font = Font.regular.withSize(.large)
                cell.textLabel?.textColor = .darkText
                cell.detailTextLabel?.textColor = .darkText
            }
            cell.imageView?.image = row.icon
            cell.textLabel?.text = row.title()
            cell.detailTextLabel?.text = self.user?.email
            
            return cell
            
        case .dob:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
            }
            cell.imageView?.image = row.icon
            cell.textField.placeholder = row.title()
            cell.label.text = row.title()
            
            let datePickerView = DatePickerSheet(with: .date, responder: cell.textField)
            datePickerView.picker.maximumDate = Date()
            cell.textField.inputView = datePickerView
            
            if let dob = self.user?.dateOfBirth {
                let dobDate = Date(timeIntervalSince1970: dob)
                cell.textField.text = dobDate.string(withFormat: .short)
                datePickerView.picker.setDate(dobDate, animated: false)
            }
            
            datePickerView.selectionHandler = { [unowned self, cell] date in
                if let date = date {
                    self.user?.dateOfBirth = date.timeIntervalSince1970
                    cell.textField.text = date.string(withFormat: .short)
                }
            }
            
            return cell
            
        case .gender:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
            }
            cell.imageView?.image = row.icon
            cell.label.text = row.title()
            cell.textField.placeholder = row.title()
            
            let values = ["VALUE_MALE".localized, "VALUE_FEMALE".localized]
            let pickerView = PickerViewSheet(with: values, responder: cell.textField)
            cell.textField.inputView = pickerView
            
            if let gender = self.user?.gender {
                cell.textField.text = gender.capitalized
                pickerView.picker.setSelectedValue(gender.capitalized)
            }
            
            pickerView.selectionHandler = { [unowned self, cell] value in
                if let gender = value as? String {
                    self.user?.gender = gender.lowercased()
                    cell.textField.text = gender
                }
            }
            
            return cell
            
        case .description:
            let cell: TextViewTableViewCell = TextViewTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
                cell.textView.font = Font.regular.withSize(.large)
                cell.iconImageView.image = .profileDescriptionIcon
                cell.textView.placeholder = "EDIT_PROFILE_DESCRIPTION".localized
            }
            cell.textView.text = self.user?.userDescription
            
            cell.textHandler = { [unowned self] text in
                self.user?.userDescription = text
            }
            
            cell.textViewSizeChangeHandler = { [unowned tableView] textView in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return cell
            
        case .over18, .calendar:
            let cell: SwitchTableViewCell = SwitchTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
            }
            cell.imageView?.image = row.icon
            cell.textLabel?.text = row.title()
            
            switch row {
            case .over18:
                cell.cellSwitch.isOn = self.user?.eighteenPlus ?? false
            case .calendar:
                cell.cellSwitch.isOn = self.user?.saveEventsToCalendar ?? false
            default:
                break
            }
            
            cell.switchHandler = { [unowned self] isOn in
                switch row {
                case .over18:
                    self.user?.eighteenPlus = isOn
                case .calendar:
                    self.user?.saveEventsToCalendar = isOn
                default:
                    break
                }
            }
            
            return cell
            
        case .interests:
            let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView) { cell in
                cell.separatorView.isHidden = true
                cell.textLabel?.font = Font.regular.withSize(.large)
                cell.textLabel?.textColor = .darkText
                cell.accessoryType = .disclosureIndicator
            }
            cell.imageView?.image = row.icon
            cell.textLabel?.text = row.title()
            
            return cell
        }
    }
}
