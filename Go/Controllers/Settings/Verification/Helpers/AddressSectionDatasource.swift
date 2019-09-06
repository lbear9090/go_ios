//
//  AddressSectionDatasource.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private enum AddressRow: Int {
    case line1
    case line2
    case city
    case county
    case postCode
    case addressCountry
    case ROW_COUNT
    
    var placeholder: String? {
        switch self {
        case .line1:
            return "ADDRESS_PH_LINE_1".localized
        case .line2:
            return "ADDRESS_PH_LINE_2".localized
        case .city:
            return "ADDRESS_PH_CITY".localized
        case .county:
            return "ADDRESS_PH_COUNTY".localized
        case .postCode:
            return "ADDRESS_PH_POST_CODE".localized
        case .addressCountry:
            return "ADDRESS_PH_COUNTRY".localized
        default:
            return nil
        }
    }
    
    func text(from address: AddressModel) -> String? {
        switch self {
        case .line1:
            return address.line1
        case .line2:
            return address.line2
        case .city:
            return address.city
        case .county:
            return address.state
        case .postCode:
            return address.postalCode
        default:
            return nil
        }
    }
    
    func setValue(_ value :String, on address: AddressModel) {
        switch self {
        case .line1:
            address.line1 = value
        case .line2:
            address.line2 = value
        case .city:
            address.city = value
        case .county:
            address.state = value
        case .postCode:
            address.postalCode = value
        default:
            break
        }
    }
}

class AddressSectionDatasource: NSObject, UITableViewDataSource {
    
    var countries: [CountryModel] = []
    var address: AddressModel?
    
    private lazy var countryPickerView: PickerViewSheet = {
        let picker = PickerViewSheet(with: countries)
        return picker
    }()
    
    //MARK: - Tableview datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddressRow.ROW_COUNT.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = AddressRow.init(rawValue: indexPath.row) else  {
            fatalError("No cell available for row")
        }
            
        switch row {
        case .addressCountry:
            let cell: PickerTextFieldTableViewCell = PickerTextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = row.placeholder
            
            let countryPicker = PickerViewSheet(with: countries, responder: cell.textField)
            cell.textField.inputView = countryPicker
            
            if let country = self.address?.country {
                cell.textField.text = country.name
                countryPicker.picker.setSelectedValue(country)
            }
            
            countryPicker.selectionHandler = { [unowned self, cell] value in
                if let country = value as? CountryModel {
                    self.address?.country = country
                    cell.textField.text = country.name
                }
            }
            
            return cell
        
        default:
            let cell: TextFieldTableViewCell = TextFieldTableViewCell.reusableCell(from: tableView)
            cell.separatorView.isHidden = true
            cell.textField.placeholder = row.placeholder
            
            if let address = self.address {
                cell.textField.text = row.text(from: address)
            }
            
            cell.textHandler = { [unowned self] text in
                if let address = self.address {
                    row.setValue(text, on: address)
                }
            }
            
            return cell
        }
    }
}
