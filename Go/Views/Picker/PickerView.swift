//
//  PickerView.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

public protocol PickerValue {
    var pickerValue: String { get }
}

extension String: PickerValue {
    public var pickerValue: String {
        return self
    }
}

public typealias PickerViewSelectionHandler = (_ value: PickerValue?) -> Void

open class PickerView: UIPickerView {
    
    open var selectionHandler: PickerViewSelectionHandler?
    
    open var selectedValue: PickerValue? {
        let index = self.selectedRow(inComponent: 0)
        
        if let currentValues = self.values, index < currentValues.count {
            return currentValues[index]
        }
        
        return nil
    }
    
    var labelConfig: LabelConfig = LabelConfig(textFont: Font.regular.withSize(.large), textColor: .black)
    
    var values: [PickerValue?]?
    
    convenience init(frame: CGRect, values: [PickerValue?]) {
        self.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.values = values
        self.dataSource = self
        self.delegate = self
    }
}

// MARK: - Selected Value

extension PickerView {
    open func setSelectedValue(_ value: PickerValue?, animated: Bool = false) {
        if let matchingIndex = self.values?.index(where: { $0?.pickerValue == value?.pickerValue}) {
            self.selectRow(matchingIndex,
                           inComponent: 0,
                           animated: animated)
        }
    }
}

// MARK: - UIPickerViewDelegate

extension PickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let reusableView = view,
            let label = reusableView.viewWithTag(1) as? UILabel, row < (self.values?.count ?? 0) {
            label.text = self.values?[row]?.pickerValue
            return reusableView
        }
        else {
            let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 280.0, height: 30.0))
            
            let label = UILabel(with: self.labelConfig)
            label.translatesAutoresizingMaskIntoConstraints = true
            label.frame = CGRect(x: 0.0, y: 0.0, width: customView.frame.width, height: 24.0)
            label.textAlignment = .center
            label.tag = 1
            label.text = self.values?[row]?.pickerValue
            
            customView.addSubview(label)
            
            return customView
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectionHandler?(self.selectedValue)
    }
    
}

// MARK: - UIPickerViewDataSource

extension PickerView: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.values?.count ?? 0
    }
    
}
