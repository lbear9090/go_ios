//
//  SHOParentViewController.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SHOParentViewController: SHOViewController {

    let containerView: UIView = UIView()
    
    var activeController: UIViewController?
    
    private var initialLoad: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.initialLoad {
            self.childContainerWillLoad()
        }
    }
    
    override func setup() {
        self.view.addSubview(self.containerView)
    }
    
    override func applyConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Properties
    
    var childControllers: [UIViewController] {
        return []
    }
    
    
    // MARK: - Lifecycle Methods
    
    // Called on initial load (before first controller is added to container).
    func childContainerWillLoad() { }
    
    
    // Called before current controller is going to removed and replaced,
    // not called on initial load.
    func childContainerWillMoveTo(_ viewController: UIViewController) { }
    
    
    // Called after new controller is added, not called on initial load.
    func childContainerDidMoveTo(_ viewController: UIViewController) { }
    
    
    // MARK: - Helpers
    
    func switchToController(at index: Int) {
        let toggleControllers = self.childControllers.compactMap({ $0 })
        
        if index >= 0 && index < toggleControllers.count {
            let controller = toggleControllers[index]
            
            if !self.initialLoad {
                self.childContainerWillMoveTo(controller)
            }
            
            self.removeController(self.activeController)
            self.addController(controller)
            
            if !self.initialLoad {
                self.childContainerDidMoveTo(controller)
            }
            
            self.initialLoad = false
        }
    }
    
    func addController(_ controller: UIViewController?) {
        guard let controller = controller else {
            return
        }
        
        self.addChildViewController(controller)
        
        self.containerView.addSubview(controller.view)
        self.activeController = controller
        
        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        controller.didMove(toParentViewController: self)
    }
    
    func removeController(_ controller: UIViewController?) {
        guard let controller = self.activeController else {
            return
        }
        
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
}

