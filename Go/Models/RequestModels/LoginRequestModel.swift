//
//  LoginRequestModel.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Marshal

class LoginRequestModel {
    var grantType: String = APIConstants.grantType
    var scopes: String = APIConstants.scopes
    var clientID: String = SHOConfigurations.clientID.value
    var clientSecret: String = SHOConfigurations.clientSecret.value
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

//MARK: - Marshaling data

extension LoginRequestModel: Marshaling {
    func marshaled() -> [String: Any] {
        return [SHOConfigurations.grantTypeKey: APIConstants.grantType,
                SHOConfigurations.scopesKey: APIConstants.scopes,
                SHOConfigurations.clientIdKey: SHOConfigurations.clientID.value,
                SHOConfigurations.clientSecretKey: SHOConfigurations.clientSecret.value,
                SHOConfigurations.usernameKey: email,
                SHOConfigurations.passwordKey: password]
    }
}
