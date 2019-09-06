//
//  FiltersViewController.swift
//  Go
//
//  Created by Lucky on 09/05/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

enum FilterSection: Int {
    case categories
    case dates
    case contribution
    case SECTION_COUNT
    
    var sectionTitle: String? {
        switch self {
        case .dates:
            return "FILTER_DATES_SECTION_TITLE".localized
        case .contribution:
            return "FILTER_CONTRIBUTIONS_SECTION_TITLE".localized
        default:
            return nil
        }
    }
    
    var rowCount: Int {
        switch self {
        case .categories:
            return CategoriesRow.ROW_COUNT.rawValue
        case .dates:
            return DatesRow.ROW_COUNT.rawValue
        case .contribution:
            return ContributionsKeyRow.ROW_COUNT.rawValue
        default:
            return 0
        }
    }
}

enum CategoriesRow: Int {
    case categories
    case ROW_COUNT
    
    var title: String {
        switch self {
        case .categories:
            return "FILTER_CATEGORIES_ROW_TITLE".localized
        default:
            return ""
        }
    }
}

enum DatesRow: Int {
    case beginning
    case ending
    case ROW_COUNT
    
    var title: String {
        switch self {
        case .beginning:
            return "FILTER_BEGINNING_ROW_TITLE".localized
        case .ending:
            return "FILTER_ENDING_ROW_TITLE".localized
        default:
            return ""
        }
    }
}

enum ContributionsKeyRow: Int {
    case type
    case ROW_COUNT
    
    var title: String {
        switch self {
        case .type:
            return "FILTER_CONTRIBUTIONS_TYPE_ROW_TITLE".localized
        default:
            return ""
        }
    }
}

class FiltersViewController: SHOTableViewController {
    
    var request: FeedDataRequestModel!
    
    var selectionHandler: ((FeedDataRequestModel) -> Void)?
    
    let datePicker: DatePickerSheet = DatePickerSheet(with: .date, responder: nil)
    
    let contributionPicker: PickerViewSheet = PickerViewSheet(with: ContributionKey.contributionOptions)
    
    private lazy var doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(doneButtonTapped))
        doneButton.tintColor = .green
        return doneButton
    }()
    
    private lazy var resetButton: UIBarButtonItem = {
        let resetButton = UIBarButtonItem(title: "FILTER_RESET".localized,
                                          style: UIBarButtonItemStyle.plain,
                                          target: self,
                                          action: #selector(resetButtonTapped))
        resetButton.tintColor = .green
        return resetButton
    }()
    
    // MARK: - Initializers
    
    init(with request: FeedDataRequestModel) {
        super.init(nibName: nil, bundle: nil)
        self.request = request
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNavigationItemLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = self.doneButton
        self.navigationItem.leftBarButtonItem = self.resetButton
    }
    
    // MARK: - User Actions
    
    @objc func doneButtonTapped() {
        self.selectionHandler?(self.request)
        self.navigationController?.dismissModal()
    }
    
    @objc func resetButtonTapped() {
        self.request.contribution = .all
        self.request.startAt = nil
        self.request.endAt = nil
        self.request.tags = nil
        
        self.tableView.reloadData()
    }
}

// MARK: - UITableView Methods

extension FiltersViewController {
    // MARK: Table Cells
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return FilterSection.SECTION_COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filterSection = FilterSection(rawValue: section) else {
            assertionFailure("Invalid Filter table view configurations")
            return 0
        }
        
        return filterSection.rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SHOTableViewCell = SHOTableViewCell.reusableCell(from: tableView,
                                                                   withStyle: .value1)
        
        cell.leftSeparatorMargin = 16.0
        
        if let sectionInfo = FilterSection(rawValue: indexPath.section) {
            switch sectionInfo {
            case .categories:
                let row = CategoriesRow(rawValue: indexPath.row)
                cell.textLabel?.text = row?.title
                cell.detailTextLabel?.text = (self.request.tags?.compactMap({$0}).joined(separator: ", ")) ?? "FILTER_CATEGORIES_PLACEHOLDER".localized
                
            case .dates:
                let row = DatesRow(rawValue: indexPath.row)
                cell.textLabel?.text = row?.title
                if let startAt = self.request.startAt, row == .beginning {
                    cell.detailTextLabel?.text = Date(timeIntervalSince1970: startAt).string(withFormat: .mediumDate)
                }
                else if let endAt = self.request.endAt, row == .ending {
                    cell.detailTextLabel?.text = Date(timeIntervalSince1970: endAt).string(withFormat: .mediumDate)
                }
                else {
                    cell.detailTextLabel?.text = nil
                }
                
            case .contribution:
                let row = ContributionsKeyRow(rawValue: indexPath.row)
                cell.textLabel?.text = row?.title
                cell.detailTextLabel?.text = self.request.contribution.pickerValue
            default:
                break
            }
        }
        return cell
    }
    
    // MARK: Section Headers
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = FilterSection(rawValue: section)?.sectionTitle {
            let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
            let headerView = SectionHeaderView(frame: frame)
            
            headerView.backgroundColor = .white
            headerView.leftLabel.text = title
            headerView.leftLabel.font = Font.medium.withSize(.medium)
            headerView.leftLabel.textColor = .green
            
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if FilterSection(rawValue: section)?.sectionTitle != nil  {
            return 30
        }
        
        return 0
    }
    
    // MARK: - Cell Selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let sectionInfo = FilterSection(rawValue: indexPath.section) {
            switch sectionInfo {
            case .categories:
                let categoriesSelectionVC = CategoriesSelectionViewController()
                categoriesSelectionVC.delegate = self
                categoriesSelectionVC.setSelectedTags(self.request.tags)
                self.navigationController?.pushViewController(categoriesSelectionVC, animated: true)
                
            case .dates:
                let row = DatesRow(rawValue: indexPath.row)
                
                if row == .beginning {
                    self.datePicker.picker.date = Date(timeIntervalSince1970: self.request.startAt ?? Date().timeIntervalSince1970)
                    self.datePicker.selectionHandler = { [weak self] (date) in
                        self?.request.startAt = date?.timeIntervalSince1970
                        if let cell = tableView.cellForRow(at: indexPath) as? SHOTableViewCell,
                            let startAt = self?.request.startAt {
                            cell.detailTextLabel?.text = Date(timeIntervalSince1970: startAt).string(withFormat: .mediumDate)
                        }
                    }
                }
                else if row == .ending {
                    self.datePicker.picker.date = Date(timeIntervalSince1970: self.request.endAt ?? Date().timeIntervalSince1970)
                    self.datePicker.selectionHandler = { [weak self] (date) in
                        self?.request.endAt = date?.timeIntervalSince1970
                        if let cell = tableView.cellForRow(at: indexPath) as? SHOTableViewCell,
                            let endAt = self?.request.endAt {
                            cell.detailTextLabel?.text = Date(timeIntervalSince1970: endAt).string(withFormat: .mediumDate)
                        }
                    }
                }
                
                self.contributionPicker.hidePicker()
                self.datePicker.hidePickerWithCompletion({ [unowned self] () -> Void? in
                    self.datePicker.showPicker(onController: self)
                })
                
            case .contribution:
                
                self.contributionPicker.selectionHandler = { [weak self] (value) in
                    if let contribution = value as? ContributionKey {
                        self?.request.contribution = contribution
                        if let cell = tableView.cellForRow(at: indexPath) as? SHOTableViewCell {
                            cell.detailTextLabel?.text = self?.request.contribution.pickerValue
                        }
                    }
                }
                
                self.datePicker.hidePicker()
                self.contributionPicker.hidePickerWithCompletion({ [unowned self] () -> Void? in
                    self.contributionPicker.showPicker(onController: self)
                })
                
            default:
                break
            }
        }
    }
}

extension FiltersViewController: CategoriesSelectionControllerDelegate {
    func didUpdateFilters(to filters: [String]) {
        self.request.tags = filters
        self.tableView.reloadData()
    }
    
    
}
