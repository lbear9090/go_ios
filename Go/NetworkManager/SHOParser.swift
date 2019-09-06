//
//  SHOParser.swift
//  Go
//
//  Created by Lucky on 10/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import Marshal

open class SHOParser: NSObject {
    
    public static let SHOAPIClientDidReceiveUnauthorizedNotification: String = "SHOAPIClientUnauthorizedResponse"
    public static let SHOAPIErrorDomain: String = "com.shoapi.client"
    
    open static func parseArray<T: Unmarshaling> (JSON json: JSONObject, key: String, type: T.Type) -> Any? {
        return try? json.value(for: key) as [T]
    }
    
    open static func parseObject <T: Unmarshaling> (JSON json: JSONObject, key: String, type: T.Type) -> Any? {
        return try? json.value(for: key) as T
    }
    
    open static func parse <T: Unmarshaling> (JSON json: JSONObject, key: String? = nil, type: T.Type) throws -> Any? {
        var finalKey = "data"
        if let userKey = key {
            finalKey = "data" + "." + userKey
        }
        
        if let responseArray = parseArray(JSON: json, key: finalKey, type: T.self) {
            return responseArray
        }
        else if let responseObject = parseObject(JSON: json, key: finalKey, type: T.self) {
            return responseObject
        }
        else {
            guard let _ = try? json.value(for: "data") as [String: Any] else {
                return nil
            }
            throw self.parsingError
        }
    }
    
    open static func parseAPIGeneratedError (json: JSONObject) -> Error? {
        
        let defaultErrorString: String = NSLocalizedString("An unknown error has occurred", comment: "UNKNOWN_ERROR")
        
        let errorString: String = (try? json.value(for: "message")) ?? defaultErrorString
        let responseCode: Int = (try? json.value(for: "code")) ?? 0
        
        if responseCode == 10 || responseCode == 14 {
            //Post unauthorized notification here
            NotificationCenter.default.post(name: Notification.Name(SHOAPIClientDidReceiveUnauthorizedNotification), object: errorString)
        }
        
        let userInfo = [NSLocalizedDescriptionKey : errorString]
        
        return NSError(domain: SHOAPIErrorDomain, code: responseCode, userInfo: userInfo)
    }
    
    open static var parsingError: Error = {
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Parsing Error: Unable to parse server response", comment: "API_PARSING_ERROR")]
        return NSError(domain: SHOAPIErrorDomain, code: 0, userInfo: userInfo)
    }()
}
