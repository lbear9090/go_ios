//
//  AuthenticationNetworking.swift
//  Go
//
//  Created by Lucky on 08/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Crashlytics
import Marshal

extension SHOAPIClient {

    func login<T: Marshaling>(with requestModel: T, completionHandler: @escaping ParsingCompletionHandler) where T.MarshalType == [String: Any] {

        self.loadPOSTRequest(urlString: APIEndpoints.authToken,
                             parameters: requestModel.marshaled(),
                             type: AuthTokenWrapperModel.self) { object, apiError, code in
                                if apiError == nil {
                                    if let tokenWrapper = object as? AuthTokenWrapperModel {
                                        do {
                                            try SHOSessionManager.shared.saveSession(bearerToken: tokenWrapper.authToken.accessToken)
                                        } catch {
                                            CLSLogv("Failed to save auth token: %@", getVaList([error.localizedDescription]))
                                            completionHandler(object, error, code)
                                        }
                                        if !tokenWrapper.merge {
                                            completionHandler(tokenWrapper.authToken, nil, code)
                                            return
                                        }
                                    } else {
                                        let typeString = String(describing:type(of: object))
                                        CLSLogv("Login - Cast failed on object of type: %@", getVaList([typeString]))
                                        let userInfo = [NSLocalizedDescriptionKey: "ERROR_UNKNOWN_MESSAGE".localized]
                                        let error = NSError(domain: Constants.errorDomain, code: 0, userInfo: userInfo)
                                        completionHandler(object, error, code)
                                    }
                                }
                                completionHandler(object, apiError, code)
        }
    }

    func updatePassword(from oldPassword: String, to newPassword: String, completionHandler: @escaping ParsingCompletionHandler) {

        let params = ["user" : [
            "current_password" : oldPassword,
            "new_password" : newPassword
            ]
        ]

        self.loadPOSTRequest(urlString: APIEndpoints.changePassword.versioned,
                             parameters: params,
                             type: AuthTokenModel.self,
                             key: APIKeys.token) { (object, error, code) in
                                if error == nil {
                                    if let authToken: AuthTokenModel = object as? AuthTokenModel {
                                        do {
                                            try SHOSessionManager.shared.saveSession(bearerToken: authToken.accessToken)
                                        } catch {
                                            CLSLogv("Failed to save auth token: %@", getVaList([error.localizedDescription]))
                                            completionHandler(object, error, code)
                                        }
                                    } else {
                                        let typeString = String(describing:type(of: object))
                                        CLSLogv("Login - Cast failed on object of type: %@", getVaList([typeString]))
                                        let userInfo = [NSLocalizedDescriptionKey: "ERROR_UNKNOWN_MESSAGE".localized]
                                        let error = NSError(domain: Constants.errorDomain, code: 0, userInfo: userInfo)
                                        completionHandler(object, error, code)
                                    }
                                }
                                completionHandler(object, error, code)
        }
    }

    func register(withRequestModel requestModel: RegistrationRequestModel, completionHandler: @escaping ParsingCompletionHandler) {
        self.loadPOSTRequest(urlString: APIEndpoints.registration.versioned,
                             parameters: requestModel.marshaled(),
                             type: RegistrationModel.self,
                             completionHandler: self.registrationCompletionHandler(with: completionHandler))
    }

    func resetPassword(withEmail email: String, completionHandler: @escaping ParsingCompletionHandler) {
        let userDict = ["email": email]
        let params: [String: Any] = ["user": userDict]

        self.loadPOSTRequest(urlString: APIEndpoints.resetPassword.versioned,
                             parameters: params,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }

    func logout(with completionHandler: @escaping ParsingCompletionHandler) {

        var params: [String: Any] = [:]

        if let token = SHOSessionManager.shared.bearerToken {
            let tokenComponents = token.split(separator: " ")
            params[APIKeys.token] = tokenComponents[1]
        }
        params[APIKeys.pushToken] = UserDefaults.standard.object(forKey: UserDefaultKey.pushNotificationToken)

        self.loadPOSTRequest(urlString: APIEndpoints.revokeAuthToken,
                             parameters: params,
                             type: TypePlaceholder.self,
                             completionHandler: completionHandler)
    }

    //MARK: - Helpers

    func registrationCompletionHandler(with inputHandler: @escaping ParsingCompletionHandler) -> ParsingCompletionHandler {
        return { object, error, code  in
            if error == nil {
                if let fetchModel: RegistrationModel = object as? RegistrationModel {

                    if let authToken: AuthTokenModel = fetchModel.token {
                        do {
                            try SHOSessionManager.shared.saveSession(bearerToken: authToken.accessToken)
                        } catch {
                            CLSLogv("Failed to save auth token: %@", getVaList([error.localizedDescription]))
                            inputHandler(object, error, code)
                        }
                    } else {
                        let returnedModel = String(describing: fetchModel)
                        CLSLogv("Auth token was returned nil in model %@", getVaList([returnedModel]))
                    }

                    if let user = fetchModel.user {
                        UserDefaults.standard.set(user.userId, forKey: UserDefaultKey.currentUserId)
                        do {
                            try CacheManager.storeCurrentUser(user)
                        } catch {
                            CLSLogv("Failed to cache user: %@", getVaList([error.localizedDescription]))
                        }
                    } else {
                        let returnedModel = String(describing: fetchModel)
                        CLSLogv("User token was returned nil in model %@", getVaList([returnedModel]))
                    }
                }
                else {
                    let typeString = String(describing:type(of: object))
                    CLSLogv("Registration - Cast failed on object of type: %@", getVaList([typeString]))
                    let userInfo = [NSLocalizedDescriptionKey: "ERROR_UNKNOWN_MESSAGE".localized]
                    let error = NSError(domain: Constants.errorDomain, code: 0, userInfo: userInfo)
                    inputHandler(object, error, code)
                }
            }
            inputHandler(object, error, code)
        }
    }
}

