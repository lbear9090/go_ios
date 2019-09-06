//
//  ActivityIndicatorButton.swift
//  Go
//
//  Created by Lee Whelan on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import SnapKit
import MessageKit

class ActivityIndicatorButton: InputBarButtonItem {
    
    private var barButtomItemImage: UIImage?
    
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.activityIndicatorViewStyle = .gray
        view.hidesWhenStopped = true
        view.isHidden = true
        return view
    }()
    
    override var image: UIImage? {
        get {
            return image(for: .normal)
        }
        set {
            self.barButtomItemImage = newValue
            setImage(newValue, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(activityIndicator)
        
        self.activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showSpinner() {
        self.setImage(nil, for: .normal)
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    func dismissSpinner() {
        self.setImage(self.barButtomItemImage, for: .normal)
        self.activityIndicator.stopAnimating()
    }
    
}
