//
//  SHOUtils.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 25/09/2017.
//
//

import Foundation

public protocol GenericConfiguration {
    var value: String { get }
}

public struct SHOUtils {
    
    public static var versionBuildString: String? {
        guard let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let appBuildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
                return nil
        }
        
        return "v\(appVersionString)(\(appBuildString))"
    }
}
