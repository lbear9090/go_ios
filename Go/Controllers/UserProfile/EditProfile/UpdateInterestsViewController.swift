//
//  UpdateInterestsViewController.swift
//  Go
//
//  Created by Lucky on 19/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import TagListView

class UpdateInterestsViewController: RegisterInterestsViewController {
    
    let updatedHandler: () -> Void
    
    init(selectedTags: [TagModel], updatedHandler: @escaping () -> Void) {
        self.updatedHandler = updatedHandler
        super.init(nibName: nil, bundle: nil)
        
        self.selectedTags = selectedTags.map { (tagModel) -> TagView in
            let tagView = TagView(title: tagModel.text)
            tagView.tag = tagModel.id
            return tagView
        }
        self.validateInput()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func nextTapped() {
        let request = UserInterestsRequestModel(tagIds: self.selectedTags.map { tagView -> Int in
            return tagView.tag
        })
        
        self.showSpinner()
        
        SHOAPIClient.shared.updateMe(with: request) { (object, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
                self.updatedHandler()
            }
        }
    }

}
