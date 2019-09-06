//
//  UnderlineSegmentedControl.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
    
protocol UnderlineSegmentedControlDelegate: class {
    func underlineSegmentedControlDidChange(_ segmentedControl: UnderlineSegmentedControl)
}

class UnderlineSegmentedControl: UISegmentedControl {
    
    weak var delegate: UnderlineSegmentedControlDelegate?
    
    var borderColor: UIColor = .black
    var borderWidth: CGFloat = 1.0
    
    var selectedTextColor: UIColor = .green {
        didSet {
            self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: self.selectedTextColor,
                                         NSAttributedStringKey.font: Font.semibold.withSize(.medium)], for: .selected)
        }
    }
    
    var unselectedTextColor: UIColor = .lightText {
        didSet {
            self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: self.unselectedTextColor,
                                         NSAttributedStringKey.font: Font.semibold.withSize(.medium)], for: .normal)
        }
    }
    
    private var selectedBorder: CALayer!
    
    convenience init(items: [Any]?, selectedIndex: Int) {
        self.init(items: items)
        
        if selectedIndex < self.numberOfSegments {
            self.selectedSegmentIndex = selectedIndex
        }
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSelectedBorderFor(index: self.selectedSegmentIndex)
    }
    
    override func setup() {
        self.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        self.addTarget(self, action: #selector(segmentDidChange(_:)), for: .valueChanged)
    }
    
    @objc private func segmentDidChange(_ sender: UnderlineSegmentedControl) {
        self.updateSelectedBorderFor(index: sender.selectedSegmentIndex)
        self.delegate?.underlineSegmentedControlDidChange(sender)
    }
    
    private func updateSelectedBorderFor(index selectedIndex: Int) {
        if selectedBorder == nil {
            selectedBorder = CALayer()
        } else {
            selectedBorder.removeFromSuperlayer()
        }
        
        let segmentWidth = self.frame.width / CGFloat(self.numberOfSegments) // FIXME: Won't work for dynamic segment sizes
        let x = CGFloat(selectedIndex) * segmentWidth
        let y = self.frame.height - self.borderWidth
        
        selectedBorder.frame = CGRect(x: x, y: y, width: segmentWidth, height: self.borderWidth)
        selectedBorder.borderColor = self.borderColor.cgColor
        selectedBorder.borderWidth = self.borderWidth
        
        self.layer.addSublayer(selectedBorder)
    }
        
}
