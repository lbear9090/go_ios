//
//  SHONetworkManager.swift
//  Go
//
//  Created by Lucky on 06/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import Alamofire
import Marshal
import UIKit

public class SHOAPIClient {
    
    public typealias ParsingCompletionHandler = (_ data: Any?, _ error: Error?, _ statusCode: Int) -> Void
    
    public static let shared: SHOAPIClient = SHOAPIClient()
    
    private init() {}
    
    var baseURL: String = SHOConfigurations.baseURL.value
    
    var request: Alamofire.DataRequest?
    
    var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    private let sessionManager: SHOSessionManager = SHOSessionManager.shared
    
    //MARK: - Public Methods
    
    @discardableResult public func loadGETRequest<T: Unmarshaling> (urlString: String, parameters: Parameters = [:], type: T.Type, key: String? = nil,
                                                  completionHandler: ParsingCompletionHandler? = nil) -> DataRequest? {
        return self.loadRequest(URL: urlString, method: .get, parameters: parameters, dataType: type, key: key,
                                completionHandler: completionHandler)
    }
    
    @discardableResult public func loadPOSTRequest<T: Unmarshaling> (urlString: String, parameters: Parameters = [:], type: T.Type, key: String? = nil,
                                 completionHandler: ParsingCompletionHandler? = nil) -> DataRequest? {
        return self.loadRequest(URL: urlString, method: .post, parameters: parameters, dataType: type, key: key,
                                completionHandler: completionHandler)
    }
    
    @discardableResult public func loadPUTRequest<T: Unmarshaling> (urlString: String, parameters: Parameters = [:], type: T.Type, key: String? = nil,
                                                  completionHandler: ParsingCompletionHandler? = nil) -> DataRequest? {
        return self.loadRequest(URL: urlString, method: .put, parameters: parameters, dataType: type, key: key,
                                completionHandler: completionHandler)
    }

    @discardableResult public func loadDELETERequest<T: Unmarshaling> (urlString: String, parameters: Parameters = [:], type: T.Type, key: String? = nil,
                                                  completionHandler: ParsingCompletionHandler? = nil) -> DataRequest? {
        return self.loadRequest(URL: urlString, method: .delete, parameters: parameters, dataType: type, key: key,
                                completionHandler: completionHandler)
    }
    
    //MARK: - Private Methods
    
    private func loadRequest<T: Unmarshaling> (URL urlString: String, method: HTTPMethod = .get,
                                               parameters: Parameters = [:], dataType: T.Type? = nil, key: String? = nil,
                                               completionHandler: ParsingCompletionHandler? = nil) -> DataRequest? {
        
        do {
            
            self.configureAuthorizationHeader()
            
            var configuredURL: URL = try urlString.asURL()
            
            if method == .get || method == .delete {
                configuredURL = self.configureQueryString(url: configuredURL, parameters: parameters)
                self.request = Alamofire.request(configuredURL, method: method, headers: self.headers)
            }
            else {
                self.request = Alamofire.request(configuredURL, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.request?.responseJSON { response in
                
                if let json = response.result.value as? [String: Any] {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    print("Request: \(configuredURL.absoluteString)")
                    print("Params: \(parameters)")
                    print("Response: \(String(describing: json))")
                    
                    guard let statusCode = response.response?.statusCode,
                        (statusCode >= 200 && statusCode < 300) else {
                            //Invalid response: Parse API generated Error here
                            let error = SHOParser.parseAPIGeneratedError(json: json)
                            print("Invalid Status Code: \(error)")
                            DispatchQueue.main.async {
                                completionHandler?(nil, error, 0)
                            }
                            return
                    }
                    
                    guard let _ = dataType.self else {
                        DispatchQueue.main.async {
                            completionHandler?(json, nil, statusCode)
                        }
                        return
                    }
                    
                    do {
                        let parsedObject = try SHOParser.parse(JSON: json, key: key, type: T.self)
                        DispatchQueue.main.async {
                            completionHandler?(parsedObject, nil, statusCode)
                        }
                    }
                    catch let error {
                        print("Parsing Error: \(error)")
                        DispatchQueue.main.async {
                            completionHandler?(nil, error, statusCode)
                        }
                    }
                }
                else {
                    let fallbackError: Error? = SHOParser.parseAPIGeneratedError(json: [:])
                    var error: NSError? =  (response.result.error ?? fallbackError) as NSError?
                    print("Invalid response from server: \(String(describing: error))")
                    
                    //Request has been cancelled
                    if error?.code == -999 {
                        error = nil
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler?(nil, error, 0)
                    }
                }
            }
        }
        catch let error {
            print("Unable to create URL \(error)")
            DispatchQueue.main.async {
                completionHandler?(nil, error, 0)
            }
        }
        
        return self.request
    }
    
    private func configureQueryString(url: URL, parameters: [String: Any]) -> URL {
        if var urlComponents: URLComponents = URLComponents(string: url.absoluteString) {
            
            var queryItems: Array<URLQueryItem> = []
            
            for (key, value) in parameters {
                var queryItem: URLQueryItem
                
                if let strValue = value as? String {
                    queryItem = URLQueryItem(name: key, value: strValue)
                }
                else {
                    queryItem = URLQueryItem(name: key, value: String(describing: value))
                }
                
                queryItems.append(queryItem)
            }
            
            urlComponents.queryItems = queryItems
            
            return urlComponents.url ?? url
        }
        
        return url
    }
    
    private func configureAuthorizationHeader () {
        if let token = self.sessionManager.bearerToken,
            self.sessionManager.isLoggedIn {
            
            self.headers["Authorization"] = token
        }
        else {
            
            let clientID = SHOConfigurations.clientID.value
            let clientSecret = SHOConfigurations.clientSecret.value
            
            let authString: String = clientID + ":" + clientSecret
            
            self.headers["Authorization"] = authString.toBase64()
        }
    }
}

//MARK: - Global Func

internal func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let environment = SHOEnvironment.shared.environment
    if environment == .development {
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    }
}

//MARK: - Extension

extension String {
    
    /// Returns a URL if `self` represents a valid URL string that conforms to RFC 2396 or throws an `AFError`.
    ///
    /// - throws: An `AFError.invalidURL` if `self` is not a valid URL string.
    ///
    /// - returns: A URL or throws an `AFError`.
    public func asURL() throws -> URL {
        guard
            let baseURL = URL(string: SHOAPIClient.shared.baseURL),
            let fullURL = URL(string: self, relativeTo: baseURL) else {
                throw AFError.invalidURL(url: self)
        }
        return fullURL
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

public class TypePlaceholder: Unmarshaling {
    required public init(object: MarshaledObject) throws {}
}
