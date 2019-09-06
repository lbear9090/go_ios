//
//  Device+Helpers.swift
//  Go
//
//  Created by Lucky on 05/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

public extension Device {
    
    public func footerHeight() -> CGFloat {
        return Device().isAny(.iPhoneX) ? 80.0 : 50.0
    }
    
    public func isAny(_ device: Device) -> Bool {
        return self == device || self == .simulator(device)
    }
    
}
