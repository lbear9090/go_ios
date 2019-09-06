//
//  String+Defaults.swift
//  Go
//
//  Created by Lee Whelan on 29/09/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

public struct Validation: GenericConfiguration {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public static let emailRegex: Validation = Validation(value: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
}

// MARK: - Localization

public extension String {
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func isValid(matching regex: Validation) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", regex.value)
        return emailTest.evaluate(with: self)
    }
    
    public func isValidEmail() -> Bool {
        return self.isValid(matching: .emailRegex)
    }
}

// MARK: - Number

public extension String {
    static let numberFormatter = NumberFormatter()
    public func toNumber() -> NSNumber? {
        return String.numberFormatter.number(from: self)
    }
}

// MARK: - String Formatting

public extension String {
    public func toAttributedString(withFont originalFont: UIFont, appendingString appendedString: String = "", withFont appendedFont: UIFont? = nil) -> NSAttributedString? {
        
        let baseAttrString = NSMutableAttributedString(string: self)
        baseAttrString.addAttribute(NSAttributedStringKey.font, value: originalFont, range: NSMakeRange(0, baseAttrString.length))
        
        let appendedAttrString = NSMutableAttributedString(string: appendedString)
        
        if let appendedFont = appendedFont {
            appendedAttrString.addAttribute(NSAttributedStringKey.font, value: appendedFont, range: NSMakeRange(0, appendedAttrString.length))
        }
        
        baseAttrString.append(appendedAttrString)
        
        return baseAttrString
    }
    
    public func attributedString(with attributes: [NSAttributedStringKey: Any]) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
}

// MARK: - Date

public extension String {
    static let dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    public func date(withFormat dateformat: String) -> Date? {
        let formatter = String.dateFormatter
        formatter.dateFormat = dateformat
        
        return formatter.date(from: self)
    }
}

// MARK: - Currency

public extension String {
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    public func number(withCurrencySymbol currencySymbol: String?) -> NSNumber? {
        let defaultCurrencySymbol = String.currencyFormatter.currencySymbol
        
        String.currencyFormatter.currencySymbol = currencySymbol
        let num = String.currencyFormatter.number(from: self)
        
        String.currencyFormatter.currencySymbol = defaultCurrencySymbol
        
        return num
    }
}
