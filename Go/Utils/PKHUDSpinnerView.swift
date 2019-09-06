//
//  PKHUDSpinnerView.swift
//  Go
//
//  Created by Lee Whelan on 19/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

public class PKHUDSpinnerView: PKHUDSquareBaseView, PKHUDAnimating {
    
    public let circleLayer: CAShapeLayer = {
        var layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 2.5
        
        layer.strokeColor = UIColor.black.cgColor
        layer.strokeStart = 0
        layer.strokeEnd = 0
        return layer
    }()
    
    private(set) var isAnimating = false
    public var animationDuration : TimeInterval = 2.0
    
    public init(title: String? = nil, subtitle: String? = nil) {
        super.init(image: nil, title: title, subtitle: subtitle)
        self.commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .white
        self.imageView.layer.insertSublayer(circleLayer, at: 0)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if self.circleLayer.frame != self.imageView.bounds {
            updateCircleLayer()
        }
    }
    
    func updateCircleLayer() {
        let center = CGPoint(x: self.imageView.bounds.size.width / 2.0,
                             y: self.imageView.bounds.size.height / 2.0)
        let radius = (self.imageView.bounds.height - self.circleLayer.lineWidth) / 2.5
        
        let startAngle : CGFloat = 0.0
        let endAngle : CGFloat = 2.0 * CGFloat.pi
        
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        self.circleLayer.path = path.cgPath
        self.circleLayer.frame = self.imageView.bounds
    }
    
    func forceBeginRefreshing() {
        self.isAnimating = false
        self.beginRefreshing()
    }
    
    func beginRefreshing() {
        
        if(self.isAnimating){
            return
        }
        
        self.isAnimating = true
        
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotateAnimation.values = [
            0.0,
            Float.pi,
            (2.0 * Float.pi)
        ]
        
        
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.duration = (self.animationDuration / 2.0)
        headAnimation.fromValue = 0
        headAnimation.toValue = 0.25
        
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.duration = (self.animationDuration / 2.0)
        tailAnimation.fromValue = 0
        tailAnimation.toValue = 1
        
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnimation.beginTime = (self.animationDuration / 2.0)
        endHeadAnimation.duration = (self.animationDuration / 2.0)
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1
        
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnimation.beginTime = (self.animationDuration / 2.0)
        endTailAnimation.duration = (self.animationDuration / 2.0)
        endTailAnimation.fromValue = 1
        endTailAnimation.toValue = 1
        
        let animations = CAAnimationGroup()
        animations.duration = self.animationDuration
        animations.animations = [
            rotateAnimation,
            headAnimation,
            tailAnimation,
            endHeadAnimation,
            endTailAnimation
        ]
        animations.repeatCount = Float.infinity
        animations.isRemovedOnCompletion = false
        
        self.circleLayer.add(animations, forKey: "animations")
    }
    
    public func startAnimation() {
        self.beginRefreshing()
    }
    
    public func endAnimation () {
        self.isAnimating = false
        self.circleLayer.removeAnimation(forKey: "animations")
    }
}
