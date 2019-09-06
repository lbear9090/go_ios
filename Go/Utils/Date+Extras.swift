//
//  Date+Extras.swift
//  Go
//
//  Created by Lucky on 13/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation

public struct DateFormat: GenericConfiguration {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public static let none = DateFormat(value: "")
}

public extension Date {
    private static let dateFormatter = DateFormatter()
    
    public func string(withFormat dateformat: DateFormat) -> String? {
        let formatter = Date.dateFormatter
        formatter.dateFormat = dateformat.value
        
        return formatter.string(from: self)
    }
}
