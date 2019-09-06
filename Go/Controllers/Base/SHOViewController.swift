//
//  SHOViewController.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import Crashlytics
import PKHUD

class SHOViewController: UIViewController {
    
    private var didSetupConstraints = false
    private let logoImageView = UIImageView(image: .navBarLogo)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
    }
    
    override func loadView() {
        super.loadView()
        
        self.setup()
        
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CLSNSLogv("[%@]: ViewWillAppear", getVaList([self.className ?? "-"]))
        
        if (self.isModal()) {
            let button = UIBarButtonItem(barButtonSystemItem: .stop,
                                         target: self,
                                         action: #selector(dismissModal))
            button.tintColor = .black
            self.navigationItem.leftBarButtonItem = button
        } else {
            self.configureNavigationBarForUseInTabBar()
            let button = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = button
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CLSNSLogv("[%@]: ViewWillDisappear", getVaList([self.className ?? "-"]))
        
        self.view.endEditing(true)
        self.title = nil
        
        NotificationCenter.default.post(name: .stopPlayingVideo, object: nil)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if !didSetupConstraints {
            self.applyConstraints()
            self.didSetupConstraints = true
        }
    }
    
    //Add call to viewDidLoad to add logo to navbar
    public func addNavigationItemLogo() {
        logoImageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = self.logoImageView
    }
}

// MARK: - NSObject

extension NSObject {
    var className: String? {
        return String(describing: type(of: self)).components(separatedBy: ".").last
    }
    
    class var className: String? {
        return String(describing: self).components(separatedBy: ".").last
    }
}

// MARK: - ViewSetup

extension SHOViewController : SHOViewSetup {

    @objc func setup() { }

    @objc func applyConstraints() { }

}


extension SHOViewController: SHOSpinner, SHOSpinnerDataSource {
    
    var spinnerView: PKHUDSquareBaseView? {
        let view = PKHUDSpinnerView()
        view.circleLayer.strokeColor = UIColor.green.cgColor
        view.startAnimation()
        return view
    }
    
}
