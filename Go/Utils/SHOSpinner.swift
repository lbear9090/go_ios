//
//  SHOSpinner.swift
//  Go
//
//  Created by Lucky on 02/11/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import PKHUD

public protocol SHOSpinner {
    var hud: PKHUD { get }
    var spinnerDataSource: SHOSpinnerDataSource? { get }
    
    func showSpinner(withTitle title: String?, subtitle: String?)
    func dismissSpinner()
}

public protocol SHOSpinnerDataSource: class {
    var spinnerView: PKHUDSquareBaseView? { get }
}

public extension SHOSpinner where Self: SHOSpinnerDataSource {
    public var spinnerDataSource: SHOSpinnerDataSource? { return self }
}

extension SHOSpinner {

    public var hud: PKHUD {
        return PKHUD.sharedHUD
    }
    
    public var spinnerDataSource: SHOSpinnerDataSource? {
        return nil
    }
    
    public var defaultSpinner: PKHUDSquareBaseView {
        return PKHUDProgressView()
    }
    
    public func showSpinner(withTitle title: String? = nil, subtitle: String? = nil ) {
        let view = self.spinnerDataSource?.spinnerView ?? self.defaultSpinner
        
        view.titleLabel.text = title
        view.subtitleLabel.text = subtitle
        self.hud.contentView = view
        
        self.hud.dimsBackground = false
        
        DispatchQueue.main.async {
            self.hud.show(onView: UIApplication.shared.keyWindow)
        }
    }
    
    public func dismissSpinner() {
        self.hud.hide(true)
    }
}
