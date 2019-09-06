//
//  InviteToEventViewController.swift
//  Go
//
//  Created by Lucky on 01/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class InviteToEventViewController: SearchSegmentedControlViewController {
    
    var event: EventModel?
    
    public lazy var buttonView: ButtonView = {
        let size = CGSize(width: self.view.bounds.width, height: 60)
        let frame = CGRect(origin: .zero, size: size)
        let view = ButtonView(frame: frame)
        
        view.button.setTitle("INVITE_OTHERS".localized, for: .normal)
        view.button.addTarget(self,
                              action: #selector(inviteOthersButtonPressed),
                              for: .touchUpInside)
        return view
    }()
    
    lazy var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(doneButtonPressed))
    
    private lazy var optionsAlertManager = OptionsAlertManager(for: self)
    
    // MARK: - View Setup
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let event = self.event {
            self.optionsAlertManager.configureBranchObjectForSharing(event)
        }
    }
    
    override func setup() {
        super.setup()
        
        self.view.addSubview(self.buttonView)
        self.navigationItem.rightBarButtonItem = self.doneButton
        self.doneButton.tintColor = .green
    }
    
    override func applyConstraints() {
        self.segmentedControlView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(SegmentedControlView.Height)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.segmentedControlView.snp.bottom)
        }
        
        self.buttonView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(self.containerView.snp.bottom)
        }
    }
    
    // MARK: - User Action
    
    @objc func inviteOthersButtonPressed() {
        if let event = self.event {
            self.optionsAlertManager.showSharingOptions(event: event)
        }
    }
    
    @objc func doneButtonPressed() {
        self.navigationController?.dismissModal()
    }
}
