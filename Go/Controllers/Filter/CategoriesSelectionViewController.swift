//
//  FilterViewController.swift
//  Go
//
//  Created by Lucky on 18/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import TagListView

protocol CategoriesSelectionControllerDelegate: class {
    func didUpdateFilters(to filters: [String])
}

class CategoriesSelectionViewController: BaseTagsViewController {

    //MARK: - Properties
    
    weak var delegate: CategoriesSelectionControllerDelegate?
    
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
    
    //MARK: - View setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "FILTER_TITLE".localized
        self.navigationItem.rightBarButtonItem = self.doneButton
        self.navigationItem.leftBarButtonItem = self.resetButton
    }
    
    //MARK: - Setters
    
    func setSelectedTags(_ tags: [String]?) {
        self.selectedTags = (tags ?? []).map { TagView(title: $0) }
    }
    
    //MARK: - User interaction
    
    @objc private func doneButtonTapped() {
        let filters: [String] = self.selectedTags.compactMap { tagView -> String? in
            return tagView.titleLabel?.text
        }
        self.delegate?.didUpdateFilters(to: filters)
        
        if self.isModal() {
            self.navigationController?.dismissModal()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func resetButtonTapped() {
        self.tagListView.selectedTags().forEach {
            $0.isSelected = false
        }
        self.selectedTags.removeAll()
        self.invalidateSelectedTags()
    }

}
