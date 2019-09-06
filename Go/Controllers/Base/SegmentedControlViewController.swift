//
//  SegmentedControlViewController.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol SegmentController: AnyObject where Self: UIViewController {
    var segmentTitle: String { get }
}

class SegmentedControlViewController: SHOParentViewController, UnderlineSegmentedControlDelegate {
    
    public var addNavBarLogo: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if addNavBarLogo {
            self.addNavigationItemLogo()
        }
    }
    
    lazy var segmentedControlView: SegmentedControlView = {
        let view: SegmentedControlView = SegmentedControlView.newAutoLayout()
        view.segmentedControl.delegate = self
        return view
    }()
    
    private var controllers: [SegmentController] = []
    
    init(with controllers: [SegmentController]) {
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        segmentedControlView.items = controllers.map { return $0.segmentTitle }
        self.controllers = controllers
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var childControllers: [UIViewController] {
        return controllers as! [UIViewController]
    }
    
    override func childContainerWillLoad() {
        self.segmentedControlView.selectedIndex = 0
        self.switchToController(at: 0)
    }
    
    override func setup() {
        super.setup()
        self.view.addSubview(segmentedControlView)
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
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(self.segmentedControlView.snp.bottom)
        }
    }
    
    // MARK: - UnderlineSegmentedControlDelegate
    
    func underlineSegmentedControlDidChange(_ segmentedControl: UnderlineSegmentedControl) {
        self.switchToController(at: segmentedControl.selectedSegmentIndex)
    }
    
}
