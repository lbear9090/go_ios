//
//  ConfigurationViewController.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

class ConfigurationViewController: SHOViewController {
    
    var backgroundImageView: UIImageView = UIImageView(image: .landingBackground)
    
    private let logoImageView: UIImageView = {
        var imageView = UIImageView(image: .authLogo)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadConfiguration()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.logoImageView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        self.backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.logoImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Network -
    
    func loadConfiguration() {
        SHOAPIClient.shared.configuration { (object, error, code) in
            if let error = error,
                (try? CacheManager.getConfigurations()) == nil {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                self.continueFlow()
            }
        }
    }
    
    // MARK: - Helpers -
    
    private func continueFlow() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if SHOSessionManager.shared.isLoggedIn {
            appDelegate.rootToFeedController()
        } else {
            appDelegate.rootToLandingController()
        }
    }
}
