//
//  Payments.swift
//  Go
//
//  Created by Lucky on 09/02/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation

extension SHOAPIClient {
    
    //MARK: - Payment cards

    func paymentMethods(withOffset offset: Int, limit: Int, completionHandler: @escaping ParsingCompletionHandler) {
        
        let params = [APIKeys.limit: limit,
                      APIKeys.offset: offset]
        
        self.loadGETRequest(urlString: APIEndpoints.paymentMethods.versioned,
                            parameters: params,
                            type: PaymentMethodModel.self,
                            key: APIKeys.paymentMethods,
                            completionHandler: completionHandler)
    }
    
    func deletePaymentMethod(with id: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.deletePaymentMethod, arguments: [id])
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: PaymentMethodModel.self,
                               key: APIKeys.paymentMethods,
                               completionHandler: completionHandler)
    }
    
    func defaultPaymentMethod(with id: Int64, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.defaultPaymentMethod, arguments: [id])
        let params = ["payment_method" : ["provider" : "stripe"]]

        self.loadPUTRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: PaymentMethodModel.self,
                            key: APIKeys.paymentMethods,
                            completionHandler: completionHandler)
    }
    
    func addPaymentMethod(with token: String, completionHandler: @escaping ParsingCompletionHandler) {
        let params = ["payment_method" : ["provider" : "stripe", "token" : token]]

        self.loadPOSTRequest(urlString: APIEndpoints.paymentMethods.versioned,
                             parameters: params,
                             type: PaymentMethodModel.self,
                             key: APIKeys.paymentMethods,
                             completionHandler: completionHandler)
    }
    
    //MARK: - Bank Accounts
    
    func payoutMethods(withOffset offset: Int, limit: Int, completionHandler: @escaping ParsingCompletionHandler) {
        let params = [APIKeys.limit: limit,
                      APIKeys.offset: offset]

        self.loadGETRequest(urlString: APIEndpoints.payoutMethods.versioned,
                            parameters: params,
                            type: BankAccountModel.self,
                            key: APIKeys.payoutMethods,
                            completionHandler: completionHandler)
    }

    func deletePayoutMethod(with id: String, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.deletePayoutMethod, arguments: [id])
        
        self.loadDELETERequest(urlString: endpoint.versioned,
                               type: BankAccountModel.self,
                               key: APIKeys.payoutMethods,
                               completionHandler: completionHandler)
    }
    
    func defaultPayoutMethod(with id: String, completionHandler: @escaping ParsingCompletionHandler) {
        
        let endpoint = String(format: APIEndpoints.defaultPayoutMethod, arguments: [id])
        let params = ["payout_method" : ["provider" : "stripe"]]
        
        self.loadPUTRequest(urlString: endpoint.versioned,
                            parameters: params,
                            type: BankAccountModel.self,
                            key: APIKeys.payoutMethods,
                            completionHandler: completionHandler)
    }
    
    func addPayoutMethod(with token: String, completionHandler: @escaping ParsingCompletionHandler) {
        let params = ["payout_method" : ["provider" : "stripe", "token" : token]]

        self.loadPOSTRequest(urlString: APIEndpoints.payoutMethods.versioned,
                             parameters: params,
                             type: BankAccountModel.self,
                             key: APIKeys.payoutMethods,
                             completionHandler: completionHandler)
    }
    
}
