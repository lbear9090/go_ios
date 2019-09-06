//
//  UINavigationBar+appearance.swift
//  Go
//
//  Created by Killian Kenny on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

extension UINavigationBar {

    func applyDefaultAppearance() {
        self.tintColor = .white
        self.barTintColor = .green
        self.isTranslucent = false
        self.shadowImage = UIImage()
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

}
