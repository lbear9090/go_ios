//
//  DatePickerSheet.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

public typealias DatePickerSelectionHandler = (_ date: Date?) -> Void

class DatePickerSheet: BasePickerViewSheet {
    
    open var selectionHandler: DatePickerSelectionHandler?
    
    open var picker: UIDatePicker!
    
    convenience init(with mode: UIDatePickerMode = .date, responder: UIResponder? = nil) {
        self.init()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.responder = responder
        
        self.configurePickerWith(mode: mode)
    }
    
    private func configurePickerWith(mode: UIDatePickerMode) {
        self.picker = UIDatePicker()
        self.picker.backgroundColor = .white
        self.picker.datePickerMode = mode
        self.picker.timeZone = TimeZone.current
        self.picker.addTarget(self, action: #selector(datePickerChangedValue(sender:)), for: .valueChanged)
    }
    
    override func pickerLoaded() {
        super.pickerLoaded()
        
        self.selectionHandler?(self.picker.date)
    }
}

extension DatePickerSheet {
    
    // MARK: - View Setup
    
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
    
    // MARK: - Date Picker Callback
    
    @objc func datePickerChangedValue(sender: UIDatePicker) {
        self.selectionHandler?(sender.date)
    }
}
