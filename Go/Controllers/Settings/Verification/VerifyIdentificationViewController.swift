//
//  VerifyIdentificationViewController.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum VerifyIDSectionType {
    case type
    case image
}

private enum VerifyIDRow {
    case idType
    case idNumber
    case frontImage
    case backImage
    
    var placeholder: String {
        switch self {
        case .idType:
            return "VERIFY_ID_TYPE_PH".localized
        case .idNumber:
            return "VERIFY_ID_NUMBER_PH".localized
        case .frontImage:
            return "VERIFY_ID_FRONT_IMAGE".localized
        case .backImage:
            return "VERIFY_ID_BACK_IMAGE".localized
        }
    }
}

private struct VerifyIDSection {
    var type: VerifyIDSectionType
    var items: [VerifyIDRow]
}

class VerifyIdentityViewController: SHOTableViewController {
    
    
    let user: UserModel
    var requestModel = IdentificationRequestModel()
    
    private let sections: [VerifyIDSection] = [
        VerifyIDSection(type: .type, items: [.idType, .idNumber]),
        VerifyIDSection(type: .image, items: [.frontImage, .backImage])
    ]
    
    lazy var pickerView: PickerViewSheet = {
        var values = [IdNameModel]()
        do {
            values = try CacheManager.getConfigurations().idTypes
        } catch {
            self.showErrorAlertWith(message: "ERROR_NO_ID_TYPES".localized)
        }
        let picker = PickerViewSheet(with: values)
        return picker
    }()
    
    lazy var imagePicker = SHOImagePickerUtils(with: self)
    
    lazy var submitIDButtonView: ButtonView = {
        var view: ButtonView = ButtonView.newAutoLayout()
        view.title = "VERIFY_ID_SUBMIT".localized
        view.config = .action
        view.delegate = self
        return view
    }()
    
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
        
        self.title = "VERIFICATION_ID".localized
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.submitIDButtonView)
    }
    
    override func applyConstraints() {
        
        self.tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }
        
        self.submitIDButtonView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            
            self.tableView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            self.submitIDButtonView.snp.makeConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
            
            self.tableView.contentInset.bottom = Stylesheet.safeLayoutAreaBottomScrollInset
            
        } else {
            
            self.submitIDButtonView.snp.makeConstraints { make in
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

extension VerifyIdentityViewController: ButtonViewDelegate {
    
    func buttonView(_ view: ButtonView, didSelect button: UIButton) {
        switch self.requestModel.validate() {
        case .valid:
            uploadFrontImage()
        case .invalid(let errorString):
            self.showErrorAlertWith(message: errorString)
        }
    }
    
}

// MARK: - Networking

extension VerifyIdentityViewController {
    
    private func uploadFrontImage() {
        let image = self.requestModel.frontImage!
        let config = UploadConfig.identification(userId: self.user.userId)
        
        self.showSpinner()
        SHOS3Utils.upload(image, configuration: config) { (imageUrl, error) in
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let imageUrl = imageUrl {
                self.requestModel.frontImageUrl = imageUrl
                self.uploadBackImage()
            } else {
                self.dismissSpinner()
            }
        }
    }
    
    private func uploadBackImage() {
        let image = self.requestModel.backImage!
        let config = UploadConfig.identification(userId: self.user.userId)
        
        SHOS3Utils.upload(image, configuration: config) { (imageUrl, error) in
            if let error = error {
                self.dismissSpinner()
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let imageUrl = imageUrl {
                self.requestModel.backImageUrl = imageUrl
                self.uploadIdentification()
            } else {
                self.dismissSpinner()
            }
        }
    }
    
    private func uploadIdentification() {
        SHOAPIClient.shared.addIdentification(with: self.requestModel) { (object, error, code) in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

// MARK: - UITableView Methods

extension VerifyIdentityViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundView?.alpha = 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .idType:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.topSeparatorView.isHidden = false
            cell.leftSeparatorMargin = 0
            cell.textField.textColor = .text
            cell.textField.placeholder = row.placeholder
            cell.textField.inputView = self.pickerView
            self.pickerView.selectionHandler = { [unowned self, cell] value in
                
                if let selection = value as? IdNameModel {
                    cell.textLabel?.text = selection.pickerValue
                    cell.textLabel?.textColor = .text
                    self.requestModel.typeId = selection.id
                }
            }
            return cell
            
        case .idNumber:
            let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
            cell.leftSeparatorMargin = 0
            cell.textField.placeholder = row.placeholder
            
            cell.textHandler = { [weak self] text in
                self?.requestModel.idNumber = text
            }
            
            return cell
            
        case .frontImage:
            let cell: IdentificationImageTableViewCell = IdentificationImageTableViewCell.reusableCell(from: tableView)
            cell.topSeparatorView.isHidden = false
            cell.idLabel.text = "VERIFY_ID_FRONT_IMAGE".localized
            cell.setImage(self.requestModel.frontImage)
            return cell
            
        case .backImage:
            let cell: IdentificationImageTableViewCell = IdentificationImageTableViewCell.reusableCell(from: tableView)
            cell.idLabel.text = "VERIFY_ID_BACK_IMAGE".localized
            cell.setImage(self.requestModel.backImage)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = self.sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .frontImage:
            self.imagePicker.openImageActionSheet(withSelectionHandler: { [unowned self] (images) in
                self.requestModel.frontImage = images.first
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        case .backImage:
            self.imagePicker.openImageActionSheet(withSelectionHandler: { [unowned self] (images) in
                self.requestModel.backImage = images.first
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        default:
            break
        }
    }
}
