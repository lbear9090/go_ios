//
//  NotificationsAPI.swift
//  Go
//
//  Created by Lucky on 12/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

extension SHOAPIClient {
    
    func readNotification(withId notificationId: Int64, completionHandler: ParsingCompletionHandler? = nil) {
        let params = ["status": "read"]
        
        let endpoint = String(format: APIEndpoints.notificationsRead, notificationId)
        
        self.loadPUTRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: TypePlaceholder.self,
                            completionHandler: completionHandler)
    }
    
    func getNotifications(withOffset offset: Int, limit: Int, completionHandler: @escaping ParsingCompletionHandler) {
        
        let params = [APIKeys.limit: limit,
                      APIKeys.offset: offset]
        
        self.loadGETRequest(urlString: APIEndpoints.notifications.versioned,
                            parameters: params,
                            type: NotificationModel.self,
                            key: APIKeys.notifications,
                            completionHandler: completionHandler)
    }
    
    func registerDeviceForPushNotifications(withToken token: String, completionHandler: @escaping ParsingCompletionHandler) {
        let params: [String: Any] = ["push_token": token,
                                     "platform": "ios",
                                     "uuid": UIDevice.current.identifierForVendor?.uuidString ?? ""]
        
        self.loadPOSTRequest(urlString: APIEndpoints.deviceRegistration.versioned,
                             parameters: params,
                             type: DeviceModel.self,
                             key: APIKeys.device,
                             completionHandler: completionHandler)
    }
    
    func deactivatePushNotificationsOnDevice(withToken token: String, completionHandler: @escaping ParsingCompletionHandler) {
        let endpointString = "\(APIEndpoints.deviceRegistration.versioned)/\(token)"
        
        self.loadDELETERequest(urlString: endpointString,
                               type: DeviceModel.self,
                               key: APIKeys.device,
                               completionHandler: completionHandler)
    }
    
}
