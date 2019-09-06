//
//  PaymentMethodTableViewCell.swift
//  Go
//
//  Created by Lucky on 04/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

enum CardType: String {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case amex = "Amex"
    case discover = "Discover"
    case diners = "Diners"
    case jcb = "JCB"
    case unknown = "unknown"
    
    func cardImage() -> UIImage {
        switch self {
        case .visa:
            return #imageLiteral(resourceName: "visa")
        case .mastercard:
            return #imageLiteral(resourceName: "mastercard")
        case .amex:
            return #imageLiteral(resourceName: "amex")
        case .discover:
            return #imageLiteral(resourceName: "discover")
        case .diners:
            return #imageLiteral(resourceName: "diners")
        case .jcb:
            return #imageLiteral(resourceName: "jcb")
        default:
            return UIImage()
        }
    }
}

class PaymentMethodTableViewCell: SHOTableViewCell {
    
    override func setup() {
        super.setup()
        
        self.separatorView.isHidden = false
        self.textLabel?.font = Font.regular.withSize(.medium)
        self.detailTextLabel?.font = Font.regular.withSize(.medium)
    }
    
    public func configureFor(paymentMethod: PaymentMethodModel) {
        if let type = CardType(rawValue: paymentMethod.brand) {
            self.imageView?.image = type.cardImage()
        }
        self.textLabel?.text = "PAYMENT_CARDS_XS".localized + paymentMethod.lastFourDigits
        self.detailTextLabel?.text = "\(paymentMethod.expiryMonth)/\(paymentMethod.expiryYear)"
    }
    
    public func configureFor(payoutMethod: BankAccountModel) {
        self.imageView?.image = .accountActiveIcon
        self.textLabel?.text = "PAYOUT_CARDS_XS".localized + payoutMethod.lastFour
        self.detailTextLabel?.text = nil
    }
}
