//
//  LaunchAnimationViewController.swift
//  Go
//
//  Created by Lucky on 02/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Lottie

class LaunchAnimationViewController: SHOViewController {
    
    var finishedAnimationHandler: (() -> Void)?
    
    let animationView: LOTAnimationView = {
        let animationView = LOTAnimationView(name: "launch_animation")
        animationView.contentMode = .scaleAspectFill
        return animationView
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.playAnimation()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playAnimation),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc private func playAnimation() {
        self.animationView.play{ [unowned self] (finished) in
            if finished {
                self.finishedAnimationHandler?()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Setup
    
    override func setup() {
        super.setup()
        
        self.view.addSubview(self.animationView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.animationView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
