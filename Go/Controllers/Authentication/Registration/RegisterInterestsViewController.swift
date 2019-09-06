//
//  RegistrationInterestsViewController.swift
//  Go
//
//  Created by Lucky on 05/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import TagListView
import SnapKit
import DeviceKit

private let CollectionViewHeight: CGFloat = 40.0
private let ButtonInset: CGFloat = 40.0
private let BottomInset: CGFloat = 80.0

class RegisterInterestsViewController: BaseTagsViewController {

    //MARK: - Properties
    
    var registrationRequest = RegistrationRequestModel()
    
    private let buttonContainer = UIView()
    
    private lazy var nextButton: UIButton = {
        let button = AuthButton()
        button.setTitle("REGISTRATION_CONTINUE".localized, for: .normal)
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - View setup

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "REGISTRATION_INTERESTS_TITLE".localized
    }

    override func setup() {
        super.setup()
        
        var inset = BottomInset
        if !Device().isAny(.iPhoneX) {
            inset += 10
        }
        self.scrollView.contentInset.bottom = inset
        
        /* Container view stops taps on disabled button
           being caught by tags behind button */
        self.view.addSubview(self.buttonContainer)
        self.buttonContainer.addSubview(self.nextButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.buttonContainer.snp.makeConstraints { make in
            make.height.equalTo(Stylesheet.authButtonHeight)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-ButtonInset)
        }
        
        self.nextButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    //MARK: - User interaction
    
    func validateInput() {
        self.nextButton.isEnabled = self.selectedTags.count > 0
    }
    
    @objc func nextTapped() {
        self.registrationRequest.interests = self.selectedTags.map { tagView -> Int in
            return tagView.tag
        }
        
        self.showSpinner()
        SHOAPIClient.shared.register(withRequestModel: self.registrationRequest) { object, error, code in
            self.dismissSpinner()
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                UserDefaults.standard.set(true, forKey: UserDefaultKey.showAddFriendsPrompt)
                
                self.dismissModal()
                let appDelegate = AppDelegate.shared
                appDelegate?.rootToFeedController()
            }
        }
    }
    
    override func invalidateSelectedTags() {
        super.invalidateSelectedTags()
        self.validateInput()
    }
    
}
