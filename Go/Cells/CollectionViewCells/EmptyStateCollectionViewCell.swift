//
//  MapViewController.swift
//  Go
//
//  Created by Lucky on 17/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class EmptyStateCollectionViewCell: BaseCollectionViewCell {
 
    let imageview : UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func setup() {
        super.setup()
        self.contentView.addSubview(self.imageview)
    }
    
    override func applyConstraints() {
        self.imageview.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView.snp.margins)
        }
    }
}
