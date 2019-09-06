//
//  SHOScrollViewController.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

let ScrollViewInset: CGFloat = 15.0

class SHOScrollViewController: SHOViewController, SHOKeyboardNotifications {
    
    var keyboardNotificationObservers: [NSObjectProtocol] = []
    
    let scrollView: UIScrollView = {
        var scrollview = UIScrollView()
        scrollview.showsVerticalScrollIndicator = false
        return scrollview
    }()
    
    let contentView = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterForKeyboardNotifications()
    }
    
    override func setup() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
    }
    
    override func applyConstraints() {
        self.contentView.layoutMargins = UIEdgeInsetsMake(ScrollViewInset, ScrollViewInset, ScrollViewInset, ScrollViewInset)
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - KeyboardNotifications
    
    func animateLayoutForKeyboard(frame: CGRect) {
        self.scrollView.setContentInsetsForKeyboard(with: frame)
    }

}
