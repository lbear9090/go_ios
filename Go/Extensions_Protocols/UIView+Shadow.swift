//
//  UIView+Shadow.swift
//  Go
//
//  Created by Killian Kenny on 28/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

extension UIView {
    
    func addTopShadow(withColor color: UIColor? = nil,
                      opacity: Float? = nil,
                      radius: CGFloat? = nil,
                      offset: CGSize? = nil) {
        
        self.addShadow(withColor: color, opacity: opacity, radius: radius, offset: offset)
        let shadowRect = CGRect(x: 0, y: 0, width: self.bounds.width, height: 2)
        self.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
    }
    
    func addBottomShadow(withColor color: UIColor? = nil,
                      opacity: Float? = nil,
                      radius: CGFloat? = nil,
                      offset: CGSize? = nil) {
        
        self.addShadow(withColor: color, opacity: opacity, radius: radius, offset: offset)
        let shadowRect = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: 2)
        self.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
    }
    
    func addShadow(withColor color: UIColor? = nil,
                   opacity: Float? = nil,
                   radius: CGFloat? = nil,
                   offset: CGSize? = nil) {
        
        self.layer.shadowColor = color?.cgColor ?? UIColor.black.cgColor
        self.layer.shadowOpacity = opacity ?? 0.8
        self.layer.shadowRadius = radius ?? 2.5
        self.layer.shadowOffset = offset ?? .zero
    }
    
}
