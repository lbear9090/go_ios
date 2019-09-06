//
//  PickerViewSheet.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

open class PickerViewSheet: BasePickerViewSheet {
    
    open var selectionHandler: PickerViewSelectionHandler? {
        didSet {
            self.picker.selectionHandler = self.selectionHandler
        }
    }
    
    open var picker: PickerView!
    
    convenience init(with values: [PickerValue?], responder: UIResponder? = nil) {
        self.init()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.responder = responder
        
        self.configurePicker(with: values)
    }
    
    private func configurePicker(with values: [PickerValue?]) {
        let pickerValues = values.compactMap { $0 }
        self.picker = PickerView(frame: .zero,
                                 values: pickerValues)
        self.picker?.backgroundColor = .white
    }
    
    override func pickerLoaded() {
        super.pickerLoaded()
        
        self.selectionHandler?(self.picker.selectedValue)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.selectionHandler?(self.picker.selectedValue)
    }
}

// MARK: - View Setup

extension PickerViewSheet {
    
    override open func setup() {
        super.setup()
        self.addSubview(self.picker)
    }
    
    override open func applyConstraints() {
        super.applyConstraints()
        self.picker.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(self.toolbar.snp.bottom)
        }
    }

}
