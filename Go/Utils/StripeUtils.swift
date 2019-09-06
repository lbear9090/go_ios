//
//  StripeUtils.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import Stripe

class StripeCardManager: NSObject {
    
    typealias StripeCompletionHandler = (_ object: Any?, _ error: Error?) -> Void
    
    private(set) weak var presentingController: UIViewController!
    private var completionHandler: StripeCompletionHandler?
    
    init(withController controller: UIViewController) {
        super.init()
        self.presentingController = controller
    }
    
    func addCard(withCompletionHandler completionHandler: StripeCompletionHandler!) {
        self.completionHandler = completionHandler
        
        let theme = STPTheme()
        theme.accentColor = .green
        theme.primaryBackgroundColor = .white
        
        let configuration = STPPaymentConfiguration()
        configuration.publishableKey = Constants.stripePublishableKey
        
        let addCardController = STPAddCardViewController(configuration: configuration,
                                                         theme: theme)
        addCardController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: addCardController)
        self.presentingController.present(navigationController, animated: true, completion: nil)
    }
    
    func addAccount(withCompletionHandler completionHandler: StripeCompletionHandler?) {
        self.completionHandler = completionHandler
        
        let addAccountController = AddBankAccountViewController()
        
        if let navController = self.presentingController.navigationController {
            navController.pushViewController(addAccountController, animated: true)
        }
        else {
            let navigationController = UINavigationController(rootViewController: addAccountController)
            self.presentingController.present(navigationController, animated: true, completion: nil)
        }
    }
}

extension StripeCardManager: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.presentingController.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController,
                               didCreateToken token: STPToken,
                               completion: @escaping STPErrorBlock) {
        SHOAPIClient.shared.addPaymentMethod(with: token.tokenId) { object, error, code in
            if let error = error {
                completion(error)
            } else if let completionHandler = self.completionHandler {
                completionHandler(object, error)
            }
        }
    }
    
}
