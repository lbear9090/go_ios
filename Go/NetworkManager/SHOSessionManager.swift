//
//  SHOSessionManager.swift
//  Go
//
//  Created by Lucky on 09/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation

public class SHOSessionManager : NSObject {
    public static let shared = SHOSessionManager()
    
    private override init() {}
    
    private let keychainItem: KeychainPasswordItem = {
        return KeychainPasswordItem(service: Bundle.main.bundleIdentifier ?? "SHOSessionManager", account: String(describing: kSecAttrAccount))
    }()
    
    public var bearerToken: String? {
        return try? self.keychainItem.readPassword()
    }
    
    public var isLoggedIn: Bool {
        if let token = self.bearerToken,
                !token.isEmpty {
            return true
        }
        
        return false
    }
    
    public func saveSession (bearerToken: String?) throws {
        if let token = bearerToken,
            !token.isEmpty {
            try self.keychainItem.savePassword("Bearer " + token)
        }
    }
    
    public func clearSession () {
        try? self.keychainItem.deleteItem()
    }
}
