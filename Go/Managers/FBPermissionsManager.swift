//
//  FBPermissionsManager.swift
//  Go
//
//  Created by Lucky on 23/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import FBSDKLoginKit

enum FBPermission: String {
    case userFriends = "user_friends"
    case userEvents = "user_events"
}

class FBPermissionsManager {
    
    public static func requestUserPermission(_ permission: FBPermission, onController controller: UIViewController, with handler: @escaping (Error?) -> Void) {
        FBSDKAccessToken.refreshCurrentAccessToken { (connection, result, error) in

            if let token = FBSDKAccessToken.current(),
                token.permissions.contains(permission.rawValue) {
                self.setUserFBUID(with: handler)
            } else {
                let requiredPermissions = ["public_profile", permission.rawValue]
                SHOAPIClient.shared.getFBAccessToken(withPermissions: requiredPermissions, on: controller) { (object, error, code) in
                    if let error = error {
                        handler(error)
                    } else if object != nil {
                        self.setUserFBUID(with: handler)
                    }
                }
            }
        }
    }
    
    private static func setUserFBUID(with handler: @escaping (Error?) -> Void) {
        SHOAPIClient.shared.getFBUser(with: FBSDKAccessToken.current(), requestParams: ["id"]) { (object, error, code) in
            if let error = error {
                handler(error)
            } else if
                let fbUserDict = object as? [String: Any],
                let fbUserId = fbUserDict["id"] as? String {
                
                SHOAPIClient.shared.updateMe(with: UserFBRequestModel(userId: fbUserId)) { (object, error, code) in
                    if let error = error {
                        handler(error)
                    } else {
                        handler(nil)
                    }
                }
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "ERROR_FB_USER_NOT_PARSED".localized]
                let userParsingError = NSError(domain: Constants.errorDomain, code: 5, userInfo: userInfo)
                handler(userParsingError)
            }
        }
    }
    
}
