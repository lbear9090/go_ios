//
//  SegmentedControlView.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class SegmentedControlView: SHOView {
    
    public static let Height: CGFloat = 44.0

    var segmentedControl: UnderlineSegmentedControl = {
        var control = UnderlineSegmentedControl(items: nil, selectedIndex: 0)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.borderColor = .green
        control.selectedTextColor = .green
        control.unselectedTextColor = .lightText
        return control
    }()
    
    var items: [String]? {
        didSet {
            guard let items = self.items else {
                return
            }
            
            self.segmentedControl.removeAllSegments()
            
            for i in 0..<items.count {
                self.segmentedControl.insertSegment(withTitle: items[i], at: i, animated: false)
            }
        }
    }
    
    var selectedIndex: Int {
        get {
            return segmentedControl.selectedSegmentIndex
        }
        set {
            self.segmentedControl.selectedSegmentIndex = newValue
        }
    }
    
    override func setup() {
        super.setup()
        self.backgroundColor = .white
        self.addSubview(self.segmentedControl)
    }
    
    override func applyConstraints() {
        self.segmentedControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(SegmentedControlView.Height)
        }
    }

}
