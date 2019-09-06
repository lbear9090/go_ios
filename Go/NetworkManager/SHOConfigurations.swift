//
//  SHOConfigurations.swift
//  Go
//
//  Created by Lucky on 09/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation

public protocol APIConstantsProvider {
    static var grantType: String { get }
    static var scopes: String { get }
}

public class SHOEnvironment {
    public static let shared: SHOEnvironment = SHOEnvironment()
    private init() {}

    public var environment: Environment!
    
    public enum Environment: String {
        case development
        case beta
        case production
    }
}

public enum SHOConfigurations : String {
    private var configFilePath: String {
        return "configurations"
    }
    
    private var fileExt: String {
        return "plist"
    }
    
    case baseURL = "BaseURL"
    case clientID = "ClientID"
    case clientSecret = "ClientSecret"
    case AWSIdentidyPoolId = "AWSIdentidyPoolID"
    case AWSBucketName = "AWSS3BucketName"
    case AWSBaseURL = "AWSS3BaseURL"
    
    public var value: String {
        switch self {
        case .AWSBaseURL:
            let awsURL = readPLIST(key: self.rawValue)
            let bucketName = readPLIST(key: SHOConfigurations.AWSBucketName.rawValue)
            return String(format: awsURL, bucketName)
        default:
            return readPLIST(key: self.rawValue)
        }
    }
    
    private func readPLIST(key: String) -> String {
        guard let path = Bundle.main.path(forResource: self.configFilePath, ofType: self.fileExt),
            let fileContents = NSDictionary(contentsOfFile: path),
            let allValues = fileContents[key] as? [String : String],
            let value = allValues[SHOEnvironment.shared.environment.rawValue] else {
                return ""
        }
        
        return value
    }
    
    public static let grantTypeKey: String = "grant_type"
    public static let scopesKey: String = "scopes"
    public static let clientIdKey: String = "client_id"
    public static let clientSecretKey: String = "client_secret"
    public static let usernameKey: String = "username"
    public static let passwordKey: String = "password"
}
