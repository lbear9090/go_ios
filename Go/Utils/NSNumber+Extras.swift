//
//  NSNumber+Extras.swift
//  Go
//
//  Created by Lucky on 13/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation

public extension NSNumber {
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    public func string(withCurrencySymbol currencySymbol: String?, showZeroDecimals: Bool = true) -> String? {
        
        let formatter = NSNumber.currencyFormatter
        
        let defaultCurrencySymbol = formatter.currencySymbol
        let defaultMaxFractions = formatter.maximumFractionDigits;
        
        formatter.currencySymbol = currencySymbol
        
        let floatVal = self.floatValue
        
        if !showZeroDecimals && fmodf(floatVal, 1) == 0 {
            formatter.maximumFractionDigits = 0;
        }
        
        let currencyString = formatter.string(from: self) ?? self.stringValue
        
        formatter.currencySymbol = defaultCurrencySymbol
        formatter.maximumFractionDigits = defaultMaxFractions
        
        return currencyString
    }
    
    public func described(withSingularString singular: String, withPluralString plural: String) -> String? {
        
        if self.isEqual(to: NSNumber(value: 1)) {
            return String(format: singular, self)
        }
        
        return String(format: plural, self)
    }
}
