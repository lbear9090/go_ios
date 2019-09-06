//
//  FacebookAPI.swift
//  Go
//
//  Created by Lucky on 22/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import FBSDKLoginKit

struct FBKey {
    static let profilePermission: String = "public_profile"
    static let emailPermission: String = "email"
    static let fields: String = "fields"
    static let userID: String = "facebook_uid"
    static let accessToken: String = "facebook_access_token"
}

extension SHOAPIClient {
    
    func getFBAccessToken(withPermissions permissions: [String], on controller: UIViewController, completionHandler: @escaping ParsingCompletionHandler) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: permissions, from: controller) { result, error in
            if let error = error {
                completionHandler(nil, error, 0)
                
            }
            else if let result = result {
                if result.isCancelled {
                    completionHandler(nil, nil, 0)
                }
                else if result.declinedPermissions.count > 0 {
                    
                    let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_PERMISSIONS_DECLINED".localized]
                    let declinedPermissionError = NSError(domain: Constants.errorDomain, code: 5, userInfo: userInfo)
                    completionHandler(nil, declinedPermissionError, 0)
                }
                else {
                    completionHandler(result, nil, 0)
                }
            }
            else {
                let userInfo = [NSLocalizedDescriptionKey: "ERROR_UNKNOWN_MESSAGE".localized]
                let unknownError = NSError(domain: Constants.errorDomain, code: 0, userInfo: userInfo)
                completionHandler(nil, unknownError, 0)
            }
        }
    }
    
    func getFBUser(with accessToken: FBSDKAccessToken, requestParams: [String], completionHandler: @escaping ParsingCompletionHandler) {
        let params = [FBKey.fields: requestParams.joined(separator: ",")]
        
        guard let request = FBSDKGraphRequest(graphPath: "/me", parameters: params) else {
            let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_LOGIN_REQUEST_FAILED".localized]
            let requestError = NSError(domain: Constants.errorDomain, code: 0, userInfo: userInfo)
            completionHandler(nil, requestError, 0)
            return
        }
        
        request.start { connection, result, error in
            if let error = error {
                completionHandler(nil, error, 0)
            }
            else if let result = result as? [String: Any] {
                completionHandler(result, nil, 0)
            }
            else {
                let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_USER_NOT_PARSED".localized]
                let userParsingError = NSError(domain: Constants.errorDomain, code: 5, userInfo: userInfo)
                completionHandler(nil, userParsingError, 0)
            }
        }
    }
    
}
